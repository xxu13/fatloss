# MVP 开发计划：碳循环减脂计划助手 iOS App

> 最后更新：2026-03-30
> 仓库地址：https://github.com/xxu13/fatloss
> 开发环境：Linux (CycleEngine) + macOS (Xcode/SwiftUI/SwiftData)

---

## 总体进度

| Phase | 名称 | 状态 | 开发环境 | 备注 |
|-------|------|------|----------|------|
| 0 | 项目脚手架 | 已完成 | Linux + macOS | CycleEngine Package + Xcode 项目均已创建 |
| 1 | CycleEngine 核心引擎 | 已完成 | Linux | 50 个测试全部通过，Swift 6.3 |
| 2 | SwiftData 数据层 | 已完成 | Linux | 模型 + 种子加载 + 数据仓库，需 macOS 编译验证 |
| 3 | SwiftUI 界面 | 已完成 | Linux | 12 个文件，4 个 ViewModel + 8 个 View，需 macOS 编译验证 |
| 4 | 本地通知 | 已完成 | Linux | NotificationManager，需 macOS 编译验证 |
| 5 | 联调测试与打磨 | 待开始 | macOS | 需要 Xcode |

## 任务清单

### Phase 0: 项目脚手架 -- 已完成

- [x] 0.1 创建 CycleEngine Swift Package (`Packages/CycleEngine/`) -- 2026-03-27 Linux
- [x] 0.2 创建 Xcode 项目 fatloss（SwiftUI, SwiftData） -- 2026-03-28 macOS
  - 项目名：`fatloss`，Bundle ID：`xin.fatloss`
  - iOS Deployment Target：26.4（Xcode 默认，后续可按需降低）
- [x] 0.3 在 Xcode 中添加 CycleEngine 为本地 Package 依赖 -- 2026-03-28 macOS
  - 路径：`Packages/CycleEngine`，已在 project.pbxproj 中确认链接正常
- [x] 0.4 将 JSON 种子数据复制到 App Bundle -- 2026-03-28 macOS
  - 位置：`fatloss/Resources/Data/*.json`（foods / training_templates / meal_templates / rules）

### Phase 1: CycleEngine 核心引擎 -- 已完成

- [x] 1.1 数据模型 -- 2026-03-27 Linux
  - Food, Nutrients, FoodDatabase, EquivalentSwapGroup
  - TrainingTemplate, TrainingDayPlan, TrainingTemplateFile
  - MealTemplate, DayMealPlan, Meal, MealItem, MealTemplateFile
  - MacroTargets, UserParams, Gender
  - AdjustmentRule, RuleCondition, RuleAction, RuleLimits, GlobalConfig, RulesFile
  - 全部实现 Codable + Sendable，精确匹配 JSON 格式
- [x] 1.2 计算器 -- 2026-03-27 Linux
  - BMRCalculator（Mifflin-St Jeor 公式）
  - TDEECalculator（活动因子映射 6 级强度）
  - MacroAllocator（蛋白质/碳水/脂肪分配）
  - MealPlanGenerator（从模板生成周计划 + 逐餐/逐日宏量素计算）
  - FoodSwapCalculator（equivalentSwaps 表查询 + 按营养素直接换算）
- [x] 1.3 宏量素验算器 -- 2026-03-27 Linux
  - MacroValidator（逐食材累加验算，P/C/kcal 容差 5%，Fat 容差 10%）
  - ValidationResult（pass/fail + 逐字段偏差百分比 + summary 输出）
  - 支持单日验算和整周批量验算
- [x] 1.4 规则引擎 -- 2026-03-27 Linux
  - RulesEngine（条件评估 + 动作执行 + 按优先级排序）
  - 支持 5 种规则：体重停滞、训练乏力、年龄修正、饥饿/失眠缓解、快速减重保护
  - 支持按日类型（训练日/休息日/高碳日/低碳日等）选择性应用调整
- [x] 1.5 单元测试 -- 2026-03-27 Linux
  - **50 个测试，12 个套件，全部通过**
  - 覆盖：JSON 解码、BMR、TDEE、宏量素分配、食物营养计算、逐日(Day0-6)食谱验算、
    周热量汇总、食材互换(正向/反向/交叉/按营养素)、规则引擎(5种规则+优先级+多规则并发+调整应用)、
    边界条件(零值/未知ID/零营养素)、全链路集成(BMR->TDEE->分配->验算->训练饮食模板对齐)

### Phase 2: SwiftData 数据层 -- 已完成

- [x] 2.1 SwiftData 模型 -- 2026-03-30 Linux
  - `UserProfile`：身高/体重/年龄/性别/三大项PR/蛋白质系数/提醒时间
  - `DailyPlan`：日期/碳水类型/宏量素目标/餐食(JSON Data)/训练完成/饮食完成/训练反馈
  - `WeightRecord`：日期/体重/体脂率
  - SwiftData 模型与 CycleEngine 模型完全分离
  - 已删除 Xcode 模板文件 `Item.swift`
- [x] 2.2 SeedDataLoader + ModelMapping -- 2026-03-30 Linux
  - `SeedDataLoader`：从 Bundle `Resources/Data/` 加载 4 个 JSON 到内存缓存（单例模式）
  - `ModelMapping`：SwiftData <-> CycleEngine 模型双向转换（UserParams/CarbType/Meal/MacroTargets）
- [x] 2.3 DataRepository 数据仓库 -- 2026-03-30 Linux
  - 用户档案 CRUD：`fetchProfile()` / `createOrUpdateProfile()`
  - 周计划生成：`generateWeekPlan()` 调用 MealPlanGenerator + 持久化
  - 计划查询：`fetchTodayPlan()` / `fetchWeekPlans()`
  - 训练/饮食标记：`markTrainingCompleted()` / `markMealCompleted()`
  - 体重记录：`recordWeight()` / `fetchWeightRecords()` / `latestWeight()`
  - 宏量素验算：`validateDayPlan()` 桥接 MacroValidator
- [x] 2.4 fatlossApp.swift 更新 -- 2026-03-30 Linux
  - ModelContainer schema 替换为 UserProfile + DailyPlan + WeightRecord
  - ContentView 清理模板代码，临时占位

### Phase 3: SwiftUI 界面 -- 已完成

- [x] 3.0 ViewModel 层 -- 2026-03-30 Linux
  - `ProfileViewModel`：档案表单状态管理、加载/保存
  - `TodayViewModel`：今日计划加载、训练/饮食标记、餐食解析（食材名+生熟重+营养素）
  - `WeekViewModel`：周计划查询、训练信息映射
  - `WeightViewModel`：体重记录 CRUD、趋势数据、输入验证
- [x] 3.1 App 入口与导航 -- 2026-03-30 Linux
  - ContentView：无档案 -> ProfileSetupView / 有档案 -> MainTabView
  - MainTabView：TabView 底部四标签（今日/周计划/体重/设置）
- [x] 3.2 用户档案页 Profile -- 2026-03-30 Linux
  - `ProfileSetupView`：三步引导（基本信息/身体数据/三大项PR），带步骤指示器
  - `ProfileEditView`：完整表单编辑，导航栏取消/保存
- [x] 3.3 今日计划页 Today -- 2026-03-30 Linux
  - 宏量素总览卡片（碳水类型标签 + P/C/F 分列 + 总热量）
  - 训练卡片（名称/描述/完成状态/反馈标记）
  - 训练反馈 Sheet（良好/乏力/跳过）
  - 饮食清单（逐餐展示：食材名+生重+熟重参考+单餐宏量素汇总）
  - 一键标记饮食完成
- [x] 3.4 周计划页 Week -- 2026-03-30 Linux
  - 7 天计划卡片列表（TODAY 高亮、碳水类型标签、P/C/F 微标、训练/饮食完成状态）
  - 周总计汇总（总蛋白质 + 总热量）
- [x] 3.5 体重记录页 Weight -- 2026-03-30 Linux
  - 最新体重大数字展示
  - Swift Charts 折线趋势图（catmullRom 插值）
  - 体重/体脂输入 Sheet
  - 历史记录列表（日期/体脂/体重）
- [x] 3.6 设置页 Settings -- 2026-03-30 Linux
  - 个人档案概览 + 编辑入口
  - 训练模板名称 + 食材库数量
  - 版本/CycleEngine/数据来源信息

### Phase 4: 本地通知 -- 已完成

- [x] 4.1 NotificationManager -- 2026-03-30 Linux
  - UNUserNotificationCenter 权限请求 + 状态检查
  - `scheduleDailyReminder(hour:minute:)`：每日固定时间推送今日计划
  - `schedulePreWorkoutReminder(trainingHour:)`：训练前 1 小时加餐提醒
  - `cancelAll()`：取消全部通知
  - 单例模式，与 SettingsView 集成（用户可调整提醒时间）

### Phase 5: 联调测试与打磨 -- 待开始（需 macOS）

- [ ] 5.1 CycleEngine + SwiftData + UI 全链路联调
- [ ] 5.2 验证 7 天循环计划数据准确性
- [ ] 5.3 UI 适配不同 iPhone 尺寸
- [ ] 5.4 App Icon + 启动屏

---

## 整体架构

```
+------------------------------------------+
|         SwiftUI Views (表现层)            |
+------------------------------------------+
|         ViewModels (MVVM, @Observable)    |
+------------------------------------------+
|         CycleEngine (独立 Swift Package)  |
|   BMR/TDEE计算 | 宏量素分配 | 食谱生成    |
|   宏量素验算   | 食材替换   | 规则引擎    |
+------------------------------------------+
|    SwiftData    |    JSON Seed Loader     |
|   (用户数据)    |   (食材库/模板/规则)     |
+------------------------------------------+
```

## 目录结构（当前实际）

```
/home/fatloss/                          # Git 仓库根目录
  fatloss.xcodeproj/                    # Xcode 项目文件（PBXFileSystemSynchronizedRootGroup）
  fatloss/                              # App 源码目录
    fatlossApp.swift                    # App 入口（Schema: UserProfile/DailyPlan/WeightRecord）
    ContentView.swift                   # 临时占位（Phase 3 替换为 TabView）
    Assets.xcassets/                    # 图片/颜色资源
    Resources/
      Data/                             # JSON 种子数据（已就位）
        foods.json                      # 8 种食材，中国食物成分表第6版
        training_templates.json         # 卧推专项 5 练计划
        meal_templates.json             # 7 天食谱模板，91kg 体重适配
        rules.json                      # 5 条动态调整规则
    Models/                             # SwiftData 模型（已完成）
      UserProfile.swift                 # 用户档案
      DailyPlan.swift                   # 每日计划（含餐食 JSON 存储）
      WeightRecord.swift                # 体重记录
    ViewModels/                         # MVVM ViewModel（已完成）
      ProfileViewModel.swift            # 档案表单状态 + 加载/保存
      TodayViewModel.swift              # 今日计划 + 餐食解析 + 训练标记
      WeekViewModel.swift               # 周计划查询 + 训练映射
      WeightViewModel.swift             # 体重记录 CRUD + 趋势数据
    Views/                              # SwiftUI 界面（已完成）
      MainTabView.swift                 # 底部四标签导航
      WeekView.swift                    # 7天计划卡片列表
      Today/
        TodayView.swift                 # 核心页面：宏量素+训练+饮食清单
      Profile/
        ProfileSetupView.swift          # 首次启动三步引导
        ProfileEditView.swift           # 档案编辑表单
      Weight/
        WeightView.swift                # 体重记录+趋势图
      Settings/
        SettingsView.swift              # 设置页
    Services/                           # 业务服务（已完成）
      SeedDataLoader.swift              # 种子数据加载（Bundle JSON -> 内存缓存）
      ModelMapping.swift                # SwiftData <-> CycleEngine 模型映射
      DataRepository.swift              # 数据仓库（CRUD + 计划生成 + 验算）
  fatlossTests/                         # 单元测试 target
    fatlossTests.swift
  fatlossUITests/                       # UI 测试 target
    fatlossUITests.swift
    fatlossUITestsLaunchTests.swift
  Packages/
    CycleEngine/                        # 已完成，独立 Swift Package
      Package.swift                     # swift-tools-version: 6.0, iOS 17+ / macOS 14+
      Sources/CycleEngine/
        CycleEngine.swift               # 入口：JSON 加载工厂方法
        Models/
          Food.swift                    # Food, Nutrients, FoodDatabase, EquivalentSwap*
          TrainingTemplate.swift        # TrainingTemplate, TrainingDayPlan, Intensity, CarbType
          MealTemplate.swift            # MealTemplate, DayMealPlan, Meal, MealItem, MealType
          MacroTargets.swift            # MacroTargets 值对象
          UserParams.swift              # UserParams, Gender
        Calculators/
          BMRCalculator.swift           # Mifflin-St Jeor
          TDEECalculator.swift          # 活动因子 x BMR
          MacroAllocator.swift          # P/C/F 分配
          MealPlanGenerator.swift       # 周计划生成 + 宏量素计算
          FoodSwapCalculator.swift      # 食材互换
        Validator/
          MacroValidator.swift          # 宏量素验算
        RulesEngine/
          AdjustmentRule.swift          # 规则数据模型
          RulesEngine.swift             # 条件评估 + 调整执行
      Tests/CycleEngineTests/
        CycleEngineTests.swift          # 50 个测试，12 个套件
        TestData/                       # 测试用 JSON 数据副本
  cycleplan.md                          # 碳循环饮食计划原始文档
  description.md                        # 项目架构设计文档
  MVP_PLAN.md                           # 本文件：进度管理
  README.md                             # 项目说明
```

## Xcode 项目信息

| 项目 | 值 |
|------|-----|
| 项目名 | fatloss |
| Bundle ID | xin.fatloss |
| iOS Deployment Target | 26.4 |
| Swift Version | 5.0 (Xcode 项目) / 6.0 (CycleEngine Package) |
| CycleEngine 依赖 | 本地 Package，路径 `Packages/CycleEngine`，已确认链接正常 |
| 测试 Targets | fatlossTests + fatlossUITests |
| 文件同步 | PBXFileSystemSynchronizedRootGroup（新增文件自动识别） |

## 关键技术决策

- **CycleEngine 作为独立 Swift Package**：与 App 解耦，可独立测试，未来跨平台移植
- **SwiftData 模型与引擎模型分离**：避免计算逻辑依赖持久化框架，通过 ModelMapping 桥接
- **餐食数据以 JSON Data 存储**：DailyPlan.mealsData 存储序列化的 [StoredMeal]，通过计算属性编解码
- **JSON 种子数据内嵌 Bundle**：MVP 阶段不依赖网络，完全离线可用
- **MVVM + @Observable**：iOS 17 原生状态管理，无第三方依赖

## 开发环境

| 环境 | 用途 | 当前状态 |
|------|------|----------|
| Linux (Ubuntu 24.04, Swift 6.3) | CycleEngine 开发 + 测试 + Phase 2-3 代码编写 | Phase 1-3 已完成 |
| macOS + Xcode | Xcode 项目 + SwiftUI + SwiftData 编译运行 | Phase 0 已完成，Phase 2 待编译验证 |
| Apple Developer 账号 | 真机测试 + App Store 上架 | 待注册 |

## Git 提交历史

```
fb8007c 实现 SwiftUI 界面层（Phase 3 完成）
acae187 更新 MVP_PLAN.md：标记 Phase 2 已完成
3549dcc 实现 SwiftData 数据层（Phase 2 完成）
e109f0d 更新 README：同步 Xcode 项目实际结构和进度状态
956182b 更新 MVP_PLAN.md：同步 Xcode 项目实际目录结构，标记 Phase 0 已完成
0b93c92 docs: 添加 README.md 文件
570de1d feat(ios): 接入 CycleEngine 本地包与数据资源
36f92ee Initial Commit
be290ac 实现 CycleEngine 核心引擎（Phase 1 完成）
86df59e 添加 MVP 开发计划
43d8f32 初始化项目：碳循环减脂计划助手架构与数据
```

## 下一步操作

### 在 macOS 上编译验证 Phase 2+3

1. `git pull origin main`
2. 打开 `fatloss.xcodeproj`，Xcode 会自动识别所有新增文件（PBXFileSystemSynchronizedRootGroup）
3. Build (Cmd+B) 验证 SwiftData 模型、Services、ViewModels、Views 编译通过
4. 确认 CycleEngine import 和 Swift Charts import 正常工作
5. 在模拟器中运行，验证首次启动引导流程和主界面

### 开始 Phase 5（联调测试与打磨）

1. CycleEngine + SwiftData + UI 全链路联调
2. 验证 7 天循环计划数据准确性
3. UI 适配不同 iPhone 尺寸
4. App Icon + 启动屏
