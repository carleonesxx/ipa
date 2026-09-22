import { PrismaClient } from '@prisma/client'
const prisma = new PrismaClient()
if (!(await prisma.food.count())) await prisma.food.createMany({ data: [
  { name: 'Греческий йогурт', kcal: 160, protein: 17, fat: 5, carbs: 8, fiber: 0, unit: 'порция' },
  { name: 'Куриная грудка на гриле', kcal: 280, protein: 42, fat: 12, carbs: 0, fiber: 0, unit: '100 г' },
  { name: 'Банан', kcal: 105, protein: 1, fat: 0, carbs: 27, fiber: 3, unit: 'шт' },
  { name: 'Овсяная каша с ягодами', kcal: 320, protein: 11, fat: 8, carbs: 51, fiber: 6, unit: 'порция' },
  { name: 'Авокадо', kcal: 160, protein: 2, fat: 15, carbs: 9, fiber: 7, unit: '100 г' },
  { name: 'Яйцо куриное', kcal: 78, protein: 6, fat: 5, carbs: 1, fiber: 0, unit: 'шт' },
  { name: 'Рис отварной', kcal: 130, protein: 3, fat: 0, carbs: 28, fiber: 0, unit: '100 г' },
  { name: 'Брокколи', kcal: 34, protein: 3, fat: 0, carbs: 7, fiber: 3, unit: '100 г' },
] })
if (!(await prisma.recipe.count())) await prisma.recipe.createMany({ data: [
  { name: 'Зелёная шакшука', description: 'Яйца, зелень и овощи на одной сковороде.', minutes: 15, kcal: 390, ingredients: ['яйца', 'шпинат', 'авокадо'], instructions: ['Обжарьте зелень', 'Добавьте яйца', 'Готовьте под крышкой'], tags: ['завтрак', 'быстро'] },
  { name: 'Боул с лососем', description: 'Сбалансированный боул с рисом и овощами.', minutes: 25, kcal: 520, ingredients: ['лосось', 'рис', 'брокколи'], instructions: ['Приготовьте рис', 'Запеките лосось', 'Соберите боул'], tags: ['обед', 'белок'] },
  { name: 'Йогурт с ягодами', description: 'Быстрый перекус без готовки.', minutes: 5, kcal: 240, ingredients: ['йогурт', 'ягоды', 'овсянка'], instructions: ['Смешайте ингредиенты'], tags: ['перекус', 'быстро'] },
] })
await prisma.$disconnect()
