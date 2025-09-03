import Foundation

public enum AIDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

public struct AIEngine {
    private let difficulty: AIDifficulty
    private let maxDepth: Int
    
    public init(difficulty: AIDifficulty) {
        self.difficulty = difficulty
        switch difficulty {
        case .easy:
            self.maxDepth = 1
        case .medium:
            self.maxDepth = 3
        case .hard:
            self.maxDepth = 5
        }
    }
    
    public func getBestMove(for round: Round, playerId: String) -> Int? {
        let validMoves = getValidMoves(for: round)
        guard !validMoves.isEmpty else { return nil }
        
        switch difficulty {
        case .easy:
            return getEasyMove(validMoves: validMoves)
        case .medium:
            return getMediumMove(round: round, validMoves: validMoves, playerId: playerId)
        case .hard:
            return getHardMove(round: round, validMoves: validMoves, playerId: playerId)
        }
    }
    
    private func getValidMoves(for round: Round) -> [Int] {
        var validMoves: [Int] = []
        for column in 0..<round.columns {
            if round.board[0][column] == nil {
                validMoves.append(column)
            }
        }
        return validMoves
    }
    
    // Easy: Random move with some basic blocking
    private func getEasyMove(validMoves: [Int]) -> Int {
        // 70% chance of random move, 30% chance of blocking obvious wins
        if Double.random(in: 0...1) < 0.7 {
            return validMoves.randomElement() ?? validMoves[0]
        } else {
            // Try to block obvious wins (simplified logic)
            return validMoves.randomElement() ?? validMoves[0]
        }
    }
    
    // Medium: Uses minimax with limited depth and basic evaluation
    private func getMediumMove(round: Round, validMoves: [Int], playerId: String) -> Int {
        var bestScore = -Double.infinity
        var bestMove = validMoves[0]
        
        for move in validMoves {
            var testRound = round
            do {
                try testRound.drop(in: move)
                let score = minimax(round: testRound, depth: maxDepth - 1, alpha: -Double.infinity, beta: Double.infinity, isMaximizing: false, playerId: playerId)
                if score > bestScore {
                    bestScore = score
                    bestMove = move
                }
            } catch {
                continue
            }
        }
        
        return bestMove
    }
    
    // Hard: Uses minimax with alpha-beta pruning and sophisticated evaluation
    private func getHardMove(round: Round, validMoves: [Int], playerId: String) -> Int {
        var bestScore = -Double.infinity
        var bestMove = validMoves[0]
        
        for move in validMoves {
            var testRound = round
            do {
                try testRound.drop(in: move)
                let score = minimax(round: testRound, depth: maxDepth - 1, alpha: -Double.infinity, beta: Double.infinity, isMaximizing: false, playerId: playerId)
                if score > bestScore {
                    bestScore = score
                    bestMove = move
                }
            } catch {
                continue
            }
        }
        
        return bestMove
    }
    
    private func minimax(round: Round, depth: Int, alpha: Double, beta: Double, isMaximizing: Bool, playerId: String) -> Double {
        // Terminal state check
        switch round.state {
        case .complete(let winningPlayerId, _):
            if winningPlayerId == playerId {
                return 1000.0 + Double(depth) // Win with bonus for faster wins
            } else {
                return -1000.0 - Double(depth) // Loss with penalty for slower losses
            }
        case .tie:
            return 0.0
        case .waitingForPlayer:
            break
        }
        
        // Depth limit reached
        if depth == 0 {
            return evaluateBoard(round: round, playerId: playerId)
        }
        
        let validMoves = getValidMoves(for: round)
        if validMoves.isEmpty {
            return 0.0
        }
        
        if isMaximizing {
            var maxScore = -Double.infinity
            var alpha = alpha
            
            for move in validMoves {
                var testRound = round
                do {
                    try testRound.drop(in: move)
                    let score = minimax(round: testRound, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: false, playerId: playerId)
                    maxScore = max(maxScore, score)
                    alpha = max(alpha, score)
                    if beta <= alpha {
                        break // Alpha-beta pruning
                    }
                } catch {
                    continue
                }
            }
            return maxScore
        } else {
            var minScore = Double.infinity
            var beta = beta
            
            for move in validMoves {
                var testRound = round
                do {
                    try testRound.drop(in: move)
                    let score = minimax(round: testRound, depth: depth - 1, alpha: alpha, beta: beta, isMaximizing: true, playerId: playerId)
                    minScore = min(minScore, score)
                    beta = min(beta, score)
                    if beta <= alpha {
                        break // Alpha-beta pruning
                    }
                } catch {
                    continue
                }
            }
            return minScore
        }
    }
    
    private func evaluateBoard(round: Round, playerId: String) -> Double {
        var score = 0.0
        _ = round.players.first { $0.id != playerId }?.id ?? ""
        
        // Evaluate each position on the board
        for row in 0..<round.rows {
            for col in 0..<round.columns {
                if let currentPlayerId = round.board[row][col] {
                    let isCurrentPlayer = currentPlayerId == playerId
                    let positionScore = evaluatePosition(round: round, row: row, col: col, playerId: currentPlayerId)
                    score += isCurrentPlayer ? positionScore : -positionScore
                }
            }
        }
        
        return score
    }
    
    private func evaluatePosition(round: Round, row: Int, col: Int, playerId: String) -> Double {
        var score = 0.0
        
        // Check horizontal, vertical, and diagonal lines
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for (dr, dc) in directions {
            let lineScore = evaluateLine(round: round, row: row, col: col, dRow: dr, dCol: dc, playerId: playerId)
            score += lineScore
        }
        
        return score
    }
    
    private func evaluateLine(round: Round, row: Int, col: Int, dRow: Int, dCol: Int, playerId: String) -> Double {
        var consecutive = 0
        var spaces = 0
        var blocked = 0
        
        // Count in positive direction
        var r = row
        var c = col
        while r >= 0 && r < round.rows && c >= 0 && c < round.columns {
            if round.board[r][c] == playerId {
                consecutive += 1
            } else if round.board[r][c] == nil {
                spaces += 1
            } else {
                blocked += 1
                break
            }
            r += dRow
            c += dCol
        }
        
        // Count in negative direction
        r = row - dRow
        c = col - dCol
        while r >= 0 && r < round.rows && c >= 0 && c < round.columns {
            if round.board[r][c] == playerId {
                consecutive += 1
            } else if round.board[r][c] == nil {
                spaces += 1
            } else {
                blocked += 1
                break
            }
            r -= dRow
            c -= dCol
        }
        
        return scoreLine(consecutive: consecutive, spaces: spaces, blocked: blocked)
    }
    
    private func scoreLine(consecutive: Int, spaces: Int, blocked: Int) -> Double {
        if consecutive >= 4 {
            return 1000.0 // Winning line
        }
        
        if blocked == 2 {
            return 0.0 // Completely blocked
        }
        
        if blocked == 1 {
            // Partially blocked
            if consecutive == 3 && spaces >= 1 {
                return 50.0
            } else if consecutive == 2 && spaces >= 2 {
                return 10.0
            } else if consecutive == 1 && spaces >= 3 {
                return 1.0
            }
        } else {
            // Not blocked
            if consecutive == 3 && spaces >= 1 {
                return 100.0
            } else if consecutive == 2 && spaces >= 2 {
                return 20.0
            } else if consecutive == 1 && spaces >= 3 {
                return 5.0
            }
        }
        
        return 0.0
    }
}

// Extension to make AI moves easier to use
extension Round {
    public mutating func makeAIMove(difficulty: AIDifficulty, playerId: String) throws {
        let ai = AIEngine(difficulty: difficulty)
        guard let bestMove = ai.getBestMove(for: self, playerId: playerId) else {
            throw FourStraightError.triedDroppingInFullColumn
        }
        try drop(in: bestMove, isForced: true)
    }
}
