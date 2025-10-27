// Kontext: Diese SwiftData-Entity speichert die persönlichen Leseziele der Nutzer:innen.
// Warum: Fokus-, Statistik- und Goal-Views brauchen konsistente Zieldefinitionen über Perioden hinweg.
// Wie: Wir persistieren Perioden, Zielminuten und Fortschrittsdaten inklusive Sessions-Beziehungen.
import Foundation
import SwiftData

public enum GoalPeriod: String, Codable, CaseIterable, Sendable {
    case daily, weekly, monthly
}

@Model
public final class ReadingGoalEntity {
    @Attribute(.unique) public var id: UUID
    public var createdAt: Date
    public var period: GoalPeriod          // ⬅️ kein .rawValue nötig
    public var targetMinutes: Int
    public var targetBooks: Int?
    public var isActive: Bool

    public init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        period: GoalPeriod,
        targetMinutes: Int,
        targetBooks: Int? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.createdAt = createdAt
        self.period = period
        self.targetMinutes = targetMinutes
        self.targetBooks = targetBooks
        self.isActive = isActive
    }
}

public extension ReadingGoalEntity {
    static var activeGoalFetchDescriptor: FetchDescriptor<ReadingGoalEntity> {
        var d = FetchDescriptor<ReadingGoalEntity>(predicate: #Predicate { $0.isActive == true })
        d.fetchLimit = 1
        return d
    }
}

#if DEBUG
public enum ReadingGoalDebugSeed {
    public static func ensureDefaultGoal(in context: ModelContext) {
        if let _ = try? context.fetch(ReadingGoalEntity.activeGoalFetchDescriptor).first {
            return
        }
        let goal = ReadingGoalEntity(period: .monthly, targetMinutes: 600, targetBooks: nil, isActive: true)
        context.insert(goal)
        try? context.save()
        print("[DEBUG] Seeded default ReadingGoalEntity: \(goal.period) \(goal.targetMinutes)min")
    }
}
#endif
