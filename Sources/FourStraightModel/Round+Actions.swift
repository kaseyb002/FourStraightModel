import Foundation

extension Round {
    public mutating func drop(in column: Int) throws {
        // Game must be ongoing
        guard case .waitingForPlayer(let currentID) = state else { return }
        // Column must exist
        guard column >= 0 && column < columns else { throw FourStraightError.triedDroppingInFullColumn }
        
        // Find lowest empty row in the column
        var placedRow: Int? = nil
        for r in (0..<rows).reversed() {
            if board[r][column] == nil {
                board[r][column] = currentID
                placedRow = r
                break
            }
        }
        guard let lastRow = placedRow else {
            // Column is full
            throw FourStraightError.triedDroppingInFullColumn
        }
        
        // Update game state from the last move
        updateGameState(lastRow: lastRow, lastCol: column)
    }
    
    private mutating func updateGameState(lastRow: Int, lastCol: Int) {
        if hasWon(fromRow: lastRow, col: lastCol) {
            // Winner is whoever just played (cell is guaranteed non-nil)
            let winnerID = board[lastRow][lastCol]!
            state = .complete(
                winningPlayerID: winnerID,
                positions: findWinningPositions(fromRow: lastRow, col: lastCol)
            )
        } else if isBoardFull() {
            state = .tie
        } else {
            // Advance to the other player (assumes exactly 2 players)
            if case .waitingForPlayer(let currentID) = state {
                let nextID = (players[0].id == currentID) ? players[1].id : players[0].id
                state = .waitingForPlayer(id: nextID)
            }
        }
    }
    
    private func isBoardFull() -> Bool {
        for r in 0..<rows {
            for c in 0..<columns {
                if board[r][c] == nil { return false }
            }
        }
        return true
    }
    
    private func hasWon(fromRow row: Int, col: Int) -> Bool {
        guard let id = board[row][col] else { return false }
        
        // 4 directions: horizontal, vertical, diag down-right, diag down-left
        let dirs = [(0,1), (1,0), (1,1), (1,-1)]
        for (dr, dc) in dirs {
            let count = 1
                + countDirection(row: row, col: col, dRow: dr, dCol: dc, id: id)
                + countDirection(row: row, col: col, dRow: -dr, dCol: -dc, id: id)
            if count >= winLength { return true }
        }
        return false
    }
    
    private func countDirection(row: Int, col: Int, dRow: Int, dCol: Int, id: PlayerID) -> Int {
        var r = row + dRow
        var c = col + dCol
        var n = 0
        
        while r >= 0, r < rows, c >= 0, c < columns, board[r][c] == id {
            n += 1
            r += dRow
            c += dCol
        }
        return n
    }
    
    private func findWinningPositions(fromRow row: Int, col: Int) -> [BoardPosition] {
        guard let id = board[row][col] else { return [] }
        
        // 4 directions: horizontal, vertical, diag down-right, diag down-left
        let dirs = [(0,1), (1,0), (1,1), (1,-1)]
        for (dr, dc) in dirs {
            let positions = getPositionsInDirection(row: row, col: col, dRow: dr, dCol: dc, id: id)
                + getPositionsInDirection(row: row, col: col, dRow: -dr, dCol: -dc, id: id)
                + [BoardPosition(row: row, column: col)] // Include the current position
            
            if positions.count >= winLength {
                return positions
            }
        }
        return []
    }
    
    private func getPositionsInDirection(row: Int, col: Int, dRow: Int, dCol: Int, id: PlayerID) -> [BoardPosition] {
        var r = row + dRow
        var c = col + dCol
        var positions: [BoardPosition] = []
        
        while r >= 0, r < rows, c >= 0, c < columns, board[r][c] == id {
            positions.append(BoardPosition(row: r, column: c))
            r += dRow
            c += dCol
        }
        return positions
    }
}
