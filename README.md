# Tashil ERP

نظام إدارة المنتجات والمخزون ونقاط البيع على أجهزة **SUNMI V3** (Android 13 Go)، يعمل Offline-First ويتزامن مع Firebase.

## التقنيات
- Flutter + Riverpod (Clean Architecture, Feature-First)
- Drift (SQLite) قاعدة بيانات محلية
- Firebase (Auth, Firestore, Cloud Functions) للمزامنة — المرحلة 3
- Angular + Material 3 للوحة الإدارة — المرحلة 3

## الهيكل
```
lib/
  core/database/        الجداول، قاعدة البيانات، الـ enums
  core/providers.dart   Riverpod providers
  features/
    products/           الكتالوج والبحث بالباركود والحد الأدنى
    inventory/          StockLedger (المسار الوحيد لتغيير الرصيد) والجرد
    sales/              البيع وإلغاء الفاتورة
    purchases/          استلام البضاعة ومتوسط التكلفة المرجح
    sync/               SyncOutbox وشكل البيانات المرسلة للسحابة
```

## قواعد البيانات
- **الفلوس بالقرش** (أعداد صحيحة)، والكميات أرقام عشرية عشان الأصناف بالكيلو.
- كل جدول أساسي فيه `localUuid` و`syncStatus` و`createdAt/updatedAt` و`syncedAt`.
- أي تغيير في الرصيد = تحديث `currentStock` + حركة في `StockMovements` + سطر في `SyncOutbox` **في Transaction واحدة**.
- بنود الفاتورة بتحفظ نسخة (Snapshot) من الاسم والسعر والتكلفة وقت البيع.
- مفيش حذف: الفاتورة بتتلغي (`cancelled`) مع حركة `RETURN` عكسية.
- رقم الفاتورة: `POS1-20261125-0001` (كود الجهاز + التاريخ + مسلسل يومي).

## التشغيل
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # بعد أي تعديل في الجداول
flutter test
flutter run
```

## الأمان
الريبو عام. ممنوع رفع `google-services.json` أو مفاتيح service account أو keystore — موجودين في `.gitignore`، وأسرار CI تتحط في GitHub Secrets.

## Docs

- [Multi-tenant database plan](docs/database/multi-tenant-plan.md) · [Sync strategy](docs/database/sync-strategy.md) · [ER diagram (DBML)](docs/database/tashil-erp.dbml)
