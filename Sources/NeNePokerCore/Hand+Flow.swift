/// 手番の決め方・ストリートの進め方・ハンドの終わり（ADR 0007）。
///
/// 出典は Robert's Rules of Poker（Version 11）の第 4 節: プリフロップはブラインドの次の人から、それ以降のストリートは親の次の行動できる人から。
extension Hand {
    /// 場札を開いて次のストリートへ進む（進み具合が awaitingDeal のときだけ呼ぶ）。
    public func dealNextStreet() -> Hand {
        guard result == nil, turn == nil, let street = currentStreet.next else {
            preconditionFailure("場札を開くのは賭けが終わってリバーより前のときだけ")
        }
        var next = self
        next.currentStreet = street
        next.boardCards += next.deck.prefix(street.boardCount - next.boardCards.count)
        next.deck.removeFirst(street.boardCount - boardCards.count)
        next.streetBets = Array(repeating: 0, count: 4)
        next.actedAt = Array(repeating: nil, count: 4)
        next.currentBet = 0
        next.lastRaiseSize = level.bigBlind
        return next.settled(after: button)
    }

    /// seat の行動（またはストリートの始まり）のあと、次の手番・場札を待つ・ハンドの終わりのどれかに決める。
    /// ほかの全員が降りたかオールインで、行動できる 1 人が賭けに届いているなら、もう誰も行動しない（場札を開いていくだけ）。
    func settled(after seat: Seat) -> Hand {
        var next = self
        let remaining = Seat.allCases.filter { [.active, .allIn].contains(statuses[$0.rawValue]) }
        if remaining.count == 1, let winner = remaining.first {
            next.turn = nil
            next.result = next.finish(contenders: [winner], ending: .uncontested)
            return next
        }
        let actors = Seat.allCases.filter { statuses[$0.rawValue] == .active }
        let alone = actors.count == 1 && actors.allSatisfy { streetBets[$0.rawValue] >= currentBet }
        next.turn = alone ? nil : seat.clockwiseFromNext.first(where: needsToAct)
        if next.turn == nil, currentStreet == .river {
            next.result = next.finish(contenders: Set(remaining), ending: .showdown)
        }
        return next
    }

    /// まだ行動できて、このストリートで行動していないか、いまの賭けに届いていない席。
    private func needsToAct(_ seat: Seat) -> Bool {
        let index = seat.rawValue
        return statuses[index] == .active && (actedAt[index] == nil || streetBets[index] < currentBet)
    }

    /// ポットを分けてハンドを終える。
    private func finish(contenders: Set<Seat>, ending: HandEnding) -> HandResult {
        var shown: [Seat: HandStrength] = [:]
        if ending == .showdown {
            for seat in contenders {
                shown[seat] = HandEvaluator.strength(of: CardSet.of(holes[seat.rawValue] + boardCards))
            }
        }
        let awards = PotDivision.divide(stakes, strengths: shown, button: button)
        var final = Dictionary(uniqueKeysWithValues: Seat.allCases.map { ($0, stacks[$0.rawValue]) })
        for award in awards {
            for (winner, share) in zip(award.winners, award.shares) {
                final[winner, default: 0] += share
            }
        }
        return HandResult(ending: ending, awards: awards, shown: shown, stacks: final)
    }
}
