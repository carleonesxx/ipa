import Foundation
import SwiftUI

struct User: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    let email: String
    var age: Int?
    var goal: String?
    var units: String?
    var avatarUrl: String?
    var plan: String?
}

struct AuthResponse: Codable { let token: String; let user: User }
struct UserResponse: Codable { let user: User }

struct Dashboard: Codable {
    struct Nutrition: Codable { var kcal: Double; var protein: Double; var fat: Double; var carbs: Double; var fiber: Double }
    var nutrition: Nutrition
    var water: Double
    var steps: Int
    var activeMinutes: Int
    var sleepMinutes: Int
}

struct Food: Codable, Identifiable, Hashable { let id: String; var name: String; var kcal: Double; var protein: Double; var fat: Double; var carbs: Double; var fiber: Double; var unit: String; var barcode: String? }
struct FoodList: Codable { let items: [Food] }
struct Meal: Codable, Identifiable { let id: String; var title: String; var type: String; var date: String; var kcal: Double; var protein: Double; var fat: Double; var carbs: Double; var fiber: Double }
struct MealList: Codable { let items: [Meal] }
struct WaterEntry: Codable, Identifiable { let id: String; var amount: Double; var date: String }
struct WaterList: Codable { let items: [WaterEntry] }
struct ActivityEntry: Codable, Identifiable { let id: String; var steps: Int; var distance: Double; var activeMinutes: Int; var type: String?; var duration: Int?; var source: String; var date: String }
struct ActivityList: Codable { let items: [ActivityEntry] }
struct SleepEntry: Codable, Identifiable { let id: String; var durationMinutes: Int; var source: String; var date: String }
struct SleepList: Codable { let items: [SleepEntry] }
struct Goal: Codable, Identifiable { let id: String; var title: String; var target: String; var type: String; var status: String; var progressValue: Double? }
struct GoalList: Codable { let items: [Goal] }
struct Habit: Codable, Identifiable { let id: String; var title: String; var target: String?; var active: Bool; var checkedToday: Bool? }
struct HabitList: Codable { let items: [Habit] }
struct Recipe: Codable, Identifiable { let id: String; var name: String; var description: String?; var minutes: Int; var kcal: Double; var tag: String; var image: String? }
struct RecipeList: Codable { let items: [Recipe] }
struct FavoriteList: Codable { let items: [Favorite] }
struct Favorite: Codable, Identifiable { let id: String; let recipeId: String }
struct Settings: Codable { var theme: String; var language: String; var units: String; var notifications: [String: Bool]; var privacy: [String: Bool] }
struct SettingsResponse: Codable { let settings: Settings }
struct Integration: Codable, Identifiable { var id: String { provider }; let provider: String; var status: String; var lastSyncAt: String? }
struct IntegrationsResponse: Codable { let providers: [Integration] }
struct MealPlan: Codable, Identifiable { let id: String; let date: String; var items: [MealPlanItem] }
struct MealPlanItem: Codable, Identifiable { let id: String; var type: String; var recipe: Recipe?; var food: Food? }
struct MealPlanList: Codable { let items: [MealPlan] }
struct ShoppingList: Codable, Identifiable { let id: String; var name: String; var items: [ShoppingItem] }
struct ShoppingItem: Codable, Identifiable { let id: String; var name: String; var quantity: Double; var unit: String?; var purchased: Bool }
struct ShoppingListResponse: Codable { let items: [ShoppingList] }
struct AIMessageResponse: Codable { let provider: String; let message: String }

enum Appearance: String, CaseIterable, Identifiable { case system, light, dark; var id: String { rawValue }; var colorScheme: ColorScheme? { self == .system ? nil : self == .dark ? .dark : .light } }
