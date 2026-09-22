import Foundation
import HealthKit

protocol HealthDataProvider {
    var isAvailable: Bool { get }
    func requestAuthorization() async throws
    func readToday() async throws -> HealthSnapshot
}

struct HealthSnapshot { var steps: Int; var distance: Double; var activeMinutes: Int; var sleepMinutes: Int; var source: String }

final class HealthKitManager: HealthDataProvider {
    private let store = HKHealthStore()
    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }
    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        [HKQuantityType.quantityType(forIdentifier: .stepCount), HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned), HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)].compactMap { $0 }.forEach { types.insert($0) }
        return types
    }
    func requestAuthorization() async throws {
        guard isAvailable else { throw APIError.message("HealthKit недоступен на этом устройстве") }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.requestAuthorization(toShare: [], read: readTypes) { success, error in
                if let error { continuation.resume(throwing: error) }
                else if success { continuation.resume() }
                else { continuation.resume(throwing: APIError.message("Доступ к HealthKit не предоставлен")) }
            }
        }
    }
    func readToday() async throws -> HealthSnapshot {
        guard isAvailable else { throw APIError.message("HealthKit недоступен") }
        let start = Calendar.current.startOfDay(for: Date())
        async let steps = sum(.stepCount, unit: HKUnit.count(), start: start)
        async let distance = sum(.distanceWalkingRunning, unit: HKUnit.meter(), start: start)
        async let sleep = sleepMinutes(start: start)
        return HealthSnapshot(steps: Int(try await steps), distance: try await distance, activeMinutes: 0, sleepMinutes: try await sleep, source: "healthkit")
    }
    private func sum(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit, start: Date) async throws -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return 0 }
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error { continuation.resume(throwing: error) } else { continuation.resume(returning: result?.sumQuantity()?.doubleValue(for: unit) ?? 0) }
            }
            store.execute(query)
        }
    }
    private func sleepMinutes(start: Date) async throws -> Int {
        guard let type = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return 0 }
        return try await withCheckedThrowingContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: start.addingTimeInterval(-86400), end: Date(), options: .strictStartDate)
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error { continuation.resume(throwing: error); return }
                let total = (samples as? [HKCategorySample] ?? []).filter { $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue }.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: Int(total / 60))
            }
            store.execute(query)
        }
    }
}

#if DEBUG
struct MockHealthProvider: HealthDataProvider { var isAvailable = true; func requestAuthorization() async throws {} ; func readToday() async throws -> HealthSnapshot { HealthSnapshot(steps: 0, distance: 0, activeMinutes: 0, sleepMinutes: 0, source: "mock") } }
#endif
