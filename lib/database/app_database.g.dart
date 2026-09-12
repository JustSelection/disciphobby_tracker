// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories with TableInfo<$CategoriesTable, Category>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$CategoriesTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _nameMeta = const VerificationMeta('name');
@override
late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
@override
late final GeneratedColumn<String> emoji = GeneratedColumn<String>('emoji', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
@override
late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
@override
late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>('updated_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
@override
List<GeneratedColumn> get $columns => [id, name, emoji, createdAt, updatedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'categories';
@override
VerificationContext validateIntegrity(Insertable<Category> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('name')) {
context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));} else if (isInserting) {
context.missing(_nameMeta);
}
if (data.containsKey('emoji')) {
context.handle(_emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));} else if (isInserting) {
context.missing(_emojiMeta);
}
if (data.containsKey('created_at')) {
context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));}if (data.containsKey('updated_at')) {
context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Category map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Category(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!, emoji: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}emoji'])!, createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!, updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!, );
}
@override
$CategoriesTable createAlias(String alias) {
return $CategoriesTable(attachedDatabase, alias);}}class Category extends DataClass implements Insertable<Category> 
{
final int id;
final String name;
final String emoji;
final DateTime createdAt;
final DateTime updatedAt;
const Category({required this.id, required this.name, required this.emoji, required this.createdAt, required this.updatedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['name'] = Variable<String>(name);
map['emoji'] = Variable<String>(emoji);
map['created_at'] = Variable<DateTime>(createdAt);
map['updated_at'] = Variable<DateTime>(updatedAt);
return map; 
}
CategoriesCompanion toCompanion(bool nullToAbsent) {
return CategoriesCompanion(id: Value(id),name: Value(name),emoji: Value(emoji),createdAt: Value(createdAt),updatedAt: Value(updatedAt),);
}
factory Category.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Category(id: serializer.fromJson<int>(json['id']),name: serializer.fromJson<String>(json['name']),emoji: serializer.fromJson<String>(json['emoji']),createdAt: serializer.fromJson<DateTime>(json['createdAt']),updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'name': serializer.toJson<String>(name),'emoji': serializer.toJson<String>(emoji),'createdAt': serializer.toJson<DateTime>(createdAt),'updatedAt': serializer.toJson<DateTime>(updatedAt),};}Category copyWith({int? id,String? name,String? emoji,DateTime? createdAt,DateTime? updatedAt}) => Category(id: id ?? this.id,name: name ?? this.name,emoji: emoji ?? this.emoji,createdAt: createdAt ?? this.createdAt,updatedAt: updatedAt ?? this.updatedAt,);Category copyWithCompanion(CategoriesCompanion data) {
return Category(
id: data.id.present ? data.id.value : this.id,name: data.name.present ? data.name.value : this.name,emoji: data.emoji.present ? data.emoji.value : this.emoji,createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,);
}
@override
String toString() {return (StringBuffer('Category(')..write('id: $id, ')..write('name: $name, ')..write('emoji: $emoji, ')..write('createdAt: $createdAt, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, name, emoji, createdAt, updatedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is Category && other.id == this.id && other.name == this.name && other.emoji == this.emoji && other.createdAt == this.createdAt && other.updatedAt == this.updatedAt);
}class CategoriesCompanion extends UpdateCompanion<Category> {
final Value<int> id;
final Value<String> name;
final Value<String> emoji;
final Value<DateTime> createdAt;
final Value<DateTime> updatedAt;
const CategoriesCompanion({this.id = const Value.absent(),this.name = const Value.absent(),this.emoji = const Value.absent(),this.createdAt = const Value.absent(),this.updatedAt = const Value.absent(),});
CategoriesCompanion.insert({this.id = const Value.absent(),required String name,required String emoji,this.createdAt = const Value.absent(),this.updatedAt = const Value.absent(),}): name = Value(name), emoji = Value(emoji);
static Insertable<Category> custom({Expression<int>? id, 
Expression<String>? name, 
Expression<String>? emoji, 
Expression<DateTime>? createdAt, 
Expression<DateTime>? updatedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (name != null)'name': name,if (emoji != null)'emoji': emoji,if (createdAt != null)'created_at': createdAt,if (updatedAt != null)'updated_at': updatedAt,});
}CategoriesCompanion copyWith({Value<int>? id, Value<String>? name, Value<String>? emoji, Value<DateTime>? createdAt, Value<DateTime>? updatedAt}) {
return CategoriesCompanion(id: id ?? this.id,name: name ?? this.name,emoji: emoji ?? this.emoji,createdAt: createdAt ?? this.createdAt,updatedAt: updatedAt ?? this.updatedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (name.present) {
map['name'] = Variable<String>(name.value);}
if (emoji.present) {
map['emoji'] = Variable<String>(emoji.value);}
if (createdAt.present) {
map['created_at'] = Variable<DateTime>(createdAt.value);}
if (updatedAt.present) {
map['updated_at'] = Variable<DateTime>(updatedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('CategoriesCompanion(')..write('id: $id, ')..write('name: $name, ')..write('emoji: $emoji, ')..write('createdAt: $createdAt, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
}
class $HobbyObjectsTable extends HobbyObjects with TableInfo<$HobbyObjectsTable, HobbyObject>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$HobbyObjectsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _categoryIdMeta = const VerificationMeta('categoryId');
@override
late final GeneratedColumn<int> categoryId = GeneratedColumn<int>('category_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _statusMeta = const VerificationMeta('status');
@override
late final GeneratedColumnWithTypeConverter<HobbyObjectStatus, int> status = GeneratedColumn<int>('status', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: Constant(HobbyObjectStatus.queued.index)).withConverter<HobbyObjectStatus>($HobbyObjectsTable.$converterstatus);
static const VerificationMeta _nameMeta = const VerificationMeta('name');
@override
late final GeneratedColumn<String> name = GeneratedColumn<String>('name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
@override
late final GeneratedColumn<String> emoji = GeneratedColumn<String>('emoji', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
@override
late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>('start_date', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
static const VerificationMeta _endDateMeta = const VerificationMeta('endDate');
@override
late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>('end_date', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
static const VerificationMeta _reviewTextMeta = const VerificationMeta('reviewText');
@override
late final GeneratedColumn<String> reviewText = GeneratedColumn<String>('review_text', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
@override
late final GeneratedColumn<int> rating = GeneratedColumn<int>('rating', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
@override
late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
@override
late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>('updated_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
@override
List<GeneratedColumn> get $columns => [id, categoryId, status, name, emoji, startDate, endDate, reviewText, rating, createdAt, updatedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'hobby_objects';
@override
VerificationContext validateIntegrity(Insertable<HobbyObject> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('category_id')) {
context.handle(_categoryIdMeta, categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta));} else if (isInserting) {
context.missing(_categoryIdMeta);
}
context.handle(_statusMeta, const VerificationResult.success());if (data.containsKey('name')) {
context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));} else if (isInserting) {
context.missing(_nameMeta);
}
if (data.containsKey('emoji')) {
context.handle(_emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));} else if (isInserting) {
context.missing(_emojiMeta);
}
if (data.containsKey('start_date')) {
context.handle(_startDateMeta, startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));}if (data.containsKey('end_date')) {
context.handle(_endDateMeta, endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));}if (data.containsKey('review_text')) {
context.handle(_reviewTextMeta, reviewText.isAcceptableOrUnknown(data['review_text']!, _reviewTextMeta));}if (data.containsKey('rating')) {
context.handle(_ratingMeta, rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));}if (data.containsKey('created_at')) {
context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));}if (data.containsKey('updated_at')) {
context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override HobbyObject map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return HobbyObject(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, categoryId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}category_id'])!, status: $HobbyObjectsTable.$converterstatus.fromSql(attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}status'])!), name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!, emoji: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}emoji'])!, startDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']), endDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']), reviewText: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}review_text']), rating: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rating']), createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!, updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!, );
}
@override
$HobbyObjectsTable createAlias(String alias) {
return $HobbyObjectsTable(attachedDatabase, alias);}static JsonTypeConverter2<HobbyObjectStatus,int,int> $converterstatus = const EnumIndexConverter<HobbyObjectStatus>(HobbyObjectStatus.values);}class HobbyObject extends DataClass implements Insertable<HobbyObject> 
{
final int id;
final int categoryId;
final HobbyObjectStatus status;
final String name;
final String emoji;
final DateTime? startDate;
final DateTime? endDate;
final String? reviewText;
final int? rating;
final DateTime createdAt;
final DateTime updatedAt;
const HobbyObject({required this.id, required this.categoryId, required this.status, required this.name, required this.emoji, this.startDate, this.endDate, this.reviewText, this.rating, required this.createdAt, required this.updatedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['category_id'] = Variable<int>(categoryId);
{map['status'] = Variable<int>($HobbyObjectsTable.$converterstatus.toSql(status));
}map['name'] = Variable<String>(name);
map['emoji'] = Variable<String>(emoji);
if (!nullToAbsent || startDate != null){map['start_date'] = Variable<DateTime>(startDate);
}if (!nullToAbsent || endDate != null){map['end_date'] = Variable<DateTime>(endDate);
}if (!nullToAbsent || reviewText != null){map['review_text'] = Variable<String>(reviewText);
}if (!nullToAbsent || rating != null){map['rating'] = Variable<int>(rating);
}map['created_at'] = Variable<DateTime>(createdAt);
map['updated_at'] = Variable<DateTime>(updatedAt);
return map; 
}
HobbyObjectsCompanion toCompanion(bool nullToAbsent) {
return HobbyObjectsCompanion(id: Value(id),categoryId: Value(categoryId),status: Value(status),name: Value(name),emoji: Value(emoji),startDate: startDate == null && nullToAbsent ? const Value.absent() : Value(startDate),endDate: endDate == null && nullToAbsent ? const Value.absent() : Value(endDate),reviewText: reviewText == null && nullToAbsent ? const Value.absent() : Value(reviewText),rating: rating == null && nullToAbsent ? const Value.absent() : Value(rating),createdAt: Value(createdAt),updatedAt: Value(updatedAt),);
}
factory HobbyObject.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return HobbyObject(id: serializer.fromJson<int>(json['id']),categoryId: serializer.fromJson<int>(json['categoryId']),status: $HobbyObjectsTable.$converterstatus.fromJson(serializer.fromJson<int>(json['status'])),name: serializer.fromJson<String>(json['name']),emoji: serializer.fromJson<String>(json['emoji']),startDate: serializer.fromJson<DateTime?>(json['startDate']),endDate: serializer.fromJson<DateTime?>(json['endDate']),reviewText: serializer.fromJson<String?>(json['reviewText']),rating: serializer.fromJson<int?>(json['rating']),createdAt: serializer.fromJson<DateTime>(json['createdAt']),updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'categoryId': serializer.toJson<int>(categoryId),'status': serializer.toJson<int>($HobbyObjectsTable.$converterstatus.toJson(status)),'name': serializer.toJson<String>(name),'emoji': serializer.toJson<String>(emoji),'startDate': serializer.toJson<DateTime?>(startDate),'endDate': serializer.toJson<DateTime?>(endDate),'reviewText': serializer.toJson<String?>(reviewText),'rating': serializer.toJson<int?>(rating),'createdAt': serializer.toJson<DateTime>(createdAt),'updatedAt': serializer.toJson<DateTime>(updatedAt),};}HobbyObject copyWith({int? id,int? categoryId,HobbyObjectStatus? status,String? name,String? emoji,Value<DateTime?> startDate = const Value.absent(),Value<DateTime?> endDate = const Value.absent(),Value<String?> reviewText = const Value.absent(),Value<int?> rating = const Value.absent(),DateTime? createdAt,DateTime? updatedAt}) => HobbyObject(id: id ?? this.id,categoryId: categoryId ?? this.categoryId,status: status ?? this.status,name: name ?? this.name,emoji: emoji ?? this.emoji,startDate: startDate.present ? startDate.value : this.startDate,endDate: endDate.present ? endDate.value : this.endDate,reviewText: reviewText.present ? reviewText.value : this.reviewText,rating: rating.present ? rating.value : this.rating,createdAt: createdAt ?? this.createdAt,updatedAt: updatedAt ?? this.updatedAt,);HobbyObject copyWithCompanion(HobbyObjectsCompanion data) {
return HobbyObject(
id: data.id.present ? data.id.value : this.id,categoryId: data.categoryId.present ? data.categoryId.value : this.categoryId,status: data.status.present ? data.status.value : this.status,name: data.name.present ? data.name.value : this.name,emoji: data.emoji.present ? data.emoji.value : this.emoji,startDate: data.startDate.present ? data.startDate.value : this.startDate,endDate: data.endDate.present ? data.endDate.value : this.endDate,reviewText: data.reviewText.present ? data.reviewText.value : this.reviewText,rating: data.rating.present ? data.rating.value : this.rating,createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,);
}
@override
String toString() {return (StringBuffer('HobbyObject(')..write('id: $id, ')..write('categoryId: $categoryId, ')..write('status: $status, ')..write('name: $name, ')..write('emoji: $emoji, ')..write('startDate: $startDate, ')..write('endDate: $endDate, ')..write('reviewText: $reviewText, ')..write('rating: $rating, ')..write('createdAt: $createdAt, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, categoryId, status, name, emoji, startDate, endDate, reviewText, rating, createdAt, updatedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is HobbyObject && other.id == this.id && other.categoryId == this.categoryId && other.status == this.status && other.name == this.name && other.emoji == this.emoji && other.startDate == this.startDate && other.endDate == this.endDate && other.reviewText == this.reviewText && other.rating == this.rating && other.createdAt == this.createdAt && other.updatedAt == this.updatedAt);
}class HobbyObjectsCompanion extends UpdateCompanion<HobbyObject> {
final Value<int> id;
final Value<int> categoryId;
final Value<HobbyObjectStatus> status;
final Value<String> name;
final Value<String> emoji;
final Value<DateTime?> startDate;
final Value<DateTime?> endDate;
final Value<String?> reviewText;
final Value<int?> rating;
final Value<DateTime> createdAt;
final Value<DateTime> updatedAt;
const HobbyObjectsCompanion({this.id = const Value.absent(),this.categoryId = const Value.absent(),this.status = const Value.absent(),this.name = const Value.absent(),this.emoji = const Value.absent(),this.startDate = const Value.absent(),this.endDate = const Value.absent(),this.reviewText = const Value.absent(),this.rating = const Value.absent(),this.createdAt = const Value.absent(),this.updatedAt = const Value.absent(),});
HobbyObjectsCompanion.insert({this.id = const Value.absent(),required int categoryId,this.status = const Value.absent(),required String name,required String emoji,this.startDate = const Value.absent(),this.endDate = const Value.absent(),this.reviewText = const Value.absent(),this.rating = const Value.absent(),this.createdAt = const Value.absent(),this.updatedAt = const Value.absent(),}): categoryId = Value(categoryId), name = Value(name), emoji = Value(emoji);
static Insertable<HobbyObject> custom({Expression<int>? id, 
Expression<int>? categoryId, 
Expression<int>? status, 
Expression<String>? name, 
Expression<String>? emoji, 
Expression<DateTime>? startDate, 
Expression<DateTime>? endDate, 
Expression<String>? reviewText, 
Expression<int>? rating, 
Expression<DateTime>? createdAt, 
Expression<DateTime>? updatedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (categoryId != null)'category_id': categoryId,if (status != null)'status': status,if (name != null)'name': name,if (emoji != null)'emoji': emoji,if (startDate != null)'start_date': startDate,if (endDate != null)'end_date': endDate,if (reviewText != null)'review_text': reviewText,if (rating != null)'rating': rating,if (createdAt != null)'created_at': createdAt,if (updatedAt != null)'updated_at': updatedAt,});
}HobbyObjectsCompanion copyWith({Value<int>? id, Value<int>? categoryId, Value<HobbyObjectStatus>? status, Value<String>? name, Value<String>? emoji, Value<DateTime?>? startDate, Value<DateTime?>? endDate, Value<String?>? reviewText, Value<int?>? rating, Value<DateTime>? createdAt, Value<DateTime>? updatedAt}) {
return HobbyObjectsCompanion(id: id ?? this.id,categoryId: categoryId ?? this.categoryId,status: status ?? this.status,name: name ?? this.name,emoji: emoji ?? this.emoji,startDate: startDate ?? this.startDate,endDate: endDate ?? this.endDate,reviewText: reviewText ?? this.reviewText,rating: rating ?? this.rating,createdAt: createdAt ?? this.createdAt,updatedAt: updatedAt ?? this.updatedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (categoryId.present) {
map['category_id'] = Variable<int>(categoryId.value);}
if (status.present) {
map['status'] = Variable<int>($HobbyObjectsTable.$converterstatus.toSql(status.value));}
if (name.present) {
map['name'] = Variable<String>(name.value);}
if (emoji.present) {
map['emoji'] = Variable<String>(emoji.value);}
if (startDate.present) {
map['start_date'] = Variable<DateTime>(startDate.value);}
if (endDate.present) {
map['end_date'] = Variable<DateTime>(endDate.value);}
if (reviewText.present) {
map['review_text'] = Variable<String>(reviewText.value);}
if (rating.present) {
map['rating'] = Variable<int>(rating.value);}
if (createdAt.present) {
map['created_at'] = Variable<DateTime>(createdAt.value);}
if (updatedAt.present) {
map['updated_at'] = Variable<DateTime>(updatedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('HobbyObjectsCompanion(')..write('id: $id, ')..write('categoryId: $categoryId, ')..write('status: $status, ')..write('name: $name, ')..write('emoji: $emoji, ')..write('startDate: $startDate, ')..write('endDate: $endDate, ')..write('reviewText: $reviewText, ')..write('rating: $rating, ')..write('createdAt: $createdAt, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
}
class $NotesTable extends Notes with TableInfo<$NotesTable, Note>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$NotesTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _objectIdMeta = const VerificationMeta('objectId');
@override
late final GeneratedColumn<int> objectId = GeneratedColumn<int>('object_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _contentMeta = const VerificationMeta('content');
@override
late final GeneratedColumn<String> content = GeneratedColumn<String>('content', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
@override
late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
@override
late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>('updated_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, defaultValue: currentDateAndTime);
@override
List<GeneratedColumn> get $columns => [id, objectId, content, createdAt, updatedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'notes';
@override
VerificationContext validateIntegrity(Insertable<Note> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('object_id')) {
context.handle(_objectIdMeta, objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta));} else if (isInserting) {
context.missing(_objectIdMeta);
}
if (data.containsKey('content')) {
context.handle(_contentMeta, content.isAcceptableOrUnknown(data['content']!, _contentMeta));} else if (isInserting) {
context.missing(_contentMeta);
}
if (data.containsKey('created_at')) {
context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));}if (data.containsKey('updated_at')) {
context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Note map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Note(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, objectId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}object_id'])!, content: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}content'])!, createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!, updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!, );
}
@override
$NotesTable createAlias(String alias) {
return $NotesTable(attachedDatabase, alias);}}class Note extends DataClass implements Insertable<Note> 
{
final int id;
final int objectId;
final String content;
final DateTime createdAt;
final DateTime updatedAt;
const Note({required this.id, required this.objectId, required this.content, required this.createdAt, required this.updatedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['object_id'] = Variable<int>(objectId);
map['content'] = Variable<String>(content);
map['created_at'] = Variable<DateTime>(createdAt);
map['updated_at'] = Variable<DateTime>(updatedAt);
return map; 
}
NotesCompanion toCompanion(bool nullToAbsent) {
return NotesCompanion(id: Value(id),objectId: Value(objectId),content: Value(content),createdAt: Value(createdAt),updatedAt: Value(updatedAt),);
}
factory Note.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Note(id: serializer.fromJson<int>(json['id']),objectId: serializer.fromJson<int>(json['objectId']),content: serializer.fromJson<String>(json['content']),createdAt: serializer.fromJson<DateTime>(json['createdAt']),updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'objectId': serializer.toJson<int>(objectId),'content': serializer.toJson<String>(content),'createdAt': serializer.toJson<DateTime>(createdAt),'updatedAt': serializer.toJson<DateTime>(updatedAt),};}Note copyWith({int? id,int? objectId,String? content,DateTime? createdAt,DateTime? updatedAt}) => Note(id: id ?? this.id,objectId: objectId ?? this.objectId,content: content ?? this.content,createdAt: createdAt ?? this.createdAt,updatedAt: updatedAt ?? this.updatedAt,);Note copyWithCompanion(NotesCompanion data) {
return Note(
id: data.id.present ? data.id.value : this.id,objectId: data.objectId.present ? data.objectId.value : this.objectId,content: data.content.present ? data.content.value : this.content,createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,);
}
@override
String toString() {return (StringBuffer('Note(')..write('id: $id, ')..write('objectId: $objectId, ')..write('content: $content, ')..write('createdAt: $createdAt, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, objectId, content, createdAt, updatedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is Note && other.id == this.id && other.objectId == this.objectId && other.content == this.content && other.createdAt == this.createdAt && other.updatedAt == this.updatedAt);
}class NotesCompanion extends UpdateCompanion<Note> {
final Value<int> id;
final Value<int> objectId;
final Value<String> content;
final Value<DateTime> createdAt;
final Value<DateTime> updatedAt;
const NotesCompanion({this.id = const Value.absent(),this.objectId = const Value.absent(),this.content = const Value.absent(),this.createdAt = const Value.absent(),this.updatedAt = const Value.absent(),});
NotesCompanion.insert({this.id = const Value.absent(),required int objectId,required String content,this.createdAt = const Value.absent(),this.updatedAt = const Value.absent(),}): objectId = Value(objectId), content = Value(content);
static Insertable<Note> custom({Expression<int>? id, 
Expression<int>? objectId, 
Expression<String>? content, 
Expression<DateTime>? createdAt, 
Expression<DateTime>? updatedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (objectId != null)'object_id': objectId,if (content != null)'content': content,if (createdAt != null)'created_at': createdAt,if (updatedAt != null)'updated_at': updatedAt,});
}NotesCompanion copyWith({Value<int>? id, Value<int>? objectId, Value<String>? content, Value<DateTime>? createdAt, Value<DateTime>? updatedAt}) {
return NotesCompanion(id: id ?? this.id,objectId: objectId ?? this.objectId,content: content ?? this.content,createdAt: createdAt ?? this.createdAt,updatedAt: updatedAt ?? this.updatedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (objectId.present) {
map['object_id'] = Variable<int>(objectId.value);}
if (content.present) {
map['content'] = Variable<String>(content.value);}
if (createdAt.present) {
map['created_at'] = Variable<DateTime>(createdAt.value);}
if (updatedAt.present) {
map['updated_at'] = Variable<DateTime>(updatedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('NotesCompanion(')..write('id: $id, ')..write('objectId: $objectId, ')..write('content: $content, ')..write('createdAt: $createdAt, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
}
abstract class _$AppDatabase extends GeneratedDatabase{
_$AppDatabase(QueryExecutor e): super(e);
$AppDatabaseManager get managers => $AppDatabaseManager(this);
late final $CategoriesTable categories = $CategoriesTable(this);
late final $HobbyObjectsTable hobbyObjects = $HobbyObjectsTable(this);
late final $NotesTable notes = $NotesTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [categories, hobbyObjects, notes];
}
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({Value<int> id,required String name,required String emoji,Value<DateTime> createdAt,Value<DateTime> updatedAt,});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({Value<int> id,Value<String> name,Value<String> emoji,Value<DateTime> createdAt,Value<DateTime> updatedAt,});
class $$CategoriesTableFilterComposer extends Composer<
        _$AppDatabase,
        $CategoriesTable> {
        $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get name => $composableBuilder(
      column: $table.name,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$CategoriesTableOrderingComposer extends Composer<
        _$AppDatabase,
        $CategoriesTable> {
        $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$CategoriesTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $CategoriesTable> {
        $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get name => $composableBuilder(
      column: $table.name,
      builder: (column) => column);
      
GeneratedColumn<String> get emoji => $composableBuilder(
      column: $table.emoji,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => column);
      
        }
      class $$CategoriesTableTableManager extends RootTableManager    <_$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category,BaseReferences<_$AppDatabase,$CategoriesTable,Category>),
    Category,
    PrefetchHooks Function()
    > {
    $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$CategoriesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$CategoriesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$CategoriesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> name = const Value.absent(),Value<String> emoji = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),Value<DateTime> updatedAt = const Value.absent(),})=> CategoriesCompanion(id: id,name: name,emoji: emoji,createdAt: createdAt,updatedAt: updatedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String name,required String emoji,Value<DateTime> createdAt = const Value.absent(),Value<DateTime> updatedAt = const Value.absent(),})=> CategoriesCompanion.insert(id: id,name: name,emoji: emoji,createdAt: createdAt,updatedAt: updatedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category,BaseReferences<_$AppDatabase,$CategoriesTable,Category>),
    Category,
    PrefetchHooks Function()
    >;typedef $$HobbyObjectsTableCreateCompanionBuilder = HobbyObjectsCompanion Function({Value<int> id,required int categoryId,Value<HobbyObjectStatus> status,required String name,required String emoji,Value<DateTime?> startDate,Value<DateTime?> endDate,Value<String?> reviewText,Value<int?> rating,Value<DateTime> createdAt,Value<DateTime> updatedAt,});
typedef $$HobbyObjectsTableUpdateCompanionBuilder = HobbyObjectsCompanion Function({Value<int> id,Value<int> categoryId,Value<HobbyObjectStatus> status,Value<String> name,Value<String> emoji,Value<DateTime?> startDate,Value<DateTime?> endDate,Value<String?> reviewText,Value<int?> rating,Value<DateTime> createdAt,Value<DateTime> updatedAt,});
class $$HobbyObjectsTableFilterComposer extends Composer<
        _$AppDatabase,
        $HobbyObjectsTable> {
        $$HobbyObjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get categoryId => $composableBuilder(
      column: $table.categoryId,
      builder: (column) => 
      ColumnFilters(column));
      
          ColumnWithTypeConverterFilters<HobbyObjectStatus,HobbyObjectStatus,int> get status => $composableBuilder(
      column: $table.status,
      builder: (column) => 
      ColumnWithTypeConverterFilters(column));
      
ColumnFilters<String> get name => $composableBuilder(
      column: $table.name,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get reviewText => $composableBuilder(
      column: $table.reviewText,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get rating => $composableBuilder(
      column: $table.rating,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$HobbyObjectsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $HobbyObjectsTable> {
        $$HobbyObjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get categoryId => $composableBuilder(
      column: $table.categoryId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get reviewText => $composableBuilder(
      column: $table.reviewText,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get rating => $composableBuilder(
      column: $table.rating,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$HobbyObjectsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $HobbyObjectsTable> {
        $$HobbyObjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<int> get categoryId => $composableBuilder(
      column: $table.categoryId,
      builder: (column) => column);
      
          GeneratedColumnWithTypeConverter<HobbyObjectStatus,int> get status => $composableBuilder(
      column: $table.status,
      builder: (column) => column);
      
GeneratedColumn<String> get name => $composableBuilder(
      column: $table.name,
      builder: (column) => column);
      
GeneratedColumn<String> get emoji => $composableBuilder(
      column: $table.emoji,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get startDate => $composableBuilder(
      column: $table.startDate,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get endDate => $composableBuilder(
      column: $table.endDate,
      builder: (column) => column);
      
GeneratedColumn<String> get reviewText => $composableBuilder(
      column: $table.reviewText,
      builder: (column) => column);
      
GeneratedColumn<int> get rating => $composableBuilder(
      column: $table.rating,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => column);
      
        }
      class $$HobbyObjectsTableTableManager extends RootTableManager    <_$AppDatabase,
    $HobbyObjectsTable,
    HobbyObject,
    $$HobbyObjectsTableFilterComposer,
    $$HobbyObjectsTableOrderingComposer,
    $$HobbyObjectsTableAnnotationComposer,
    $$HobbyObjectsTableCreateCompanionBuilder,
    $$HobbyObjectsTableUpdateCompanionBuilder,
    (HobbyObject,BaseReferences<_$AppDatabase,$HobbyObjectsTable,HobbyObject>),
    HobbyObject,
    PrefetchHooks Function()
    > {
    $$HobbyObjectsTableTableManager(_$AppDatabase db, $HobbyObjectsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$HobbyObjectsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$HobbyObjectsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$HobbyObjectsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<int> categoryId = const Value.absent(),Value<HobbyObjectStatus> status = const Value.absent(),Value<String> name = const Value.absent(),Value<String> emoji = const Value.absent(),Value<DateTime?> startDate = const Value.absent(),Value<DateTime?> endDate = const Value.absent(),Value<String?> reviewText = const Value.absent(),Value<int?> rating = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),Value<DateTime> updatedAt = const Value.absent(),})=> HobbyObjectsCompanion(id: id,categoryId: categoryId,status: status,name: name,emoji: emoji,startDate: startDate,endDate: endDate,reviewText: reviewText,rating: rating,createdAt: createdAt,updatedAt: updatedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required int categoryId,Value<HobbyObjectStatus> status = const Value.absent(),required String name,required String emoji,Value<DateTime?> startDate = const Value.absent(),Value<DateTime?> endDate = const Value.absent(),Value<String?> reviewText = const Value.absent(),Value<int?> rating = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),Value<DateTime> updatedAt = const Value.absent(),})=> HobbyObjectsCompanion.insert(id: id,categoryId: categoryId,status: status,name: name,emoji: emoji,startDate: startDate,endDate: endDate,reviewText: reviewText,rating: rating,createdAt: createdAt,updatedAt: updatedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$HobbyObjectsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $HobbyObjectsTable,
    HobbyObject,
    $$HobbyObjectsTableFilterComposer,
    $$HobbyObjectsTableOrderingComposer,
    $$HobbyObjectsTableAnnotationComposer,
    $$HobbyObjectsTableCreateCompanionBuilder,
    $$HobbyObjectsTableUpdateCompanionBuilder,
    (HobbyObject,BaseReferences<_$AppDatabase,$HobbyObjectsTable,HobbyObject>),
    HobbyObject,
    PrefetchHooks Function()
    >;typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({Value<int> id,required int objectId,required String content,Value<DateTime> createdAt,Value<DateTime> updatedAt,});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({Value<int> id,Value<int> objectId,Value<String> content,Value<DateTime> createdAt,Value<DateTime> updatedAt,});
class $$NotesTableFilterComposer extends Composer<
        _$AppDatabase,
        $NotesTable> {
        $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get objectId => $composableBuilder(
      column: $table.objectId,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get content => $composableBuilder(
      column: $table.content,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$NotesTableOrderingComposer extends Composer<
        _$AppDatabase,
        $NotesTable> {
        $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get objectId => $composableBuilder(
      column: $table.objectId,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$NotesTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $NotesTable> {
        $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<int> get objectId => $composableBuilder(
      column: $table.objectId,
      builder: (column) => column);
      
GeneratedColumn<String> get content => $composableBuilder(
      column: $table.content,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => column);
      
        }
      class $$NotesTableTableManager extends RootTableManager    <_$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note,BaseReferences<_$AppDatabase,$NotesTable,Note>),
    Note,
    PrefetchHooks Function()
    > {
    $$NotesTableTableManager(_$AppDatabase db, $NotesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$NotesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$NotesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$NotesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<int> objectId = const Value.absent(),Value<String> content = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),Value<DateTime> updatedAt = const Value.absent(),})=> NotesCompanion(id: id,objectId: objectId,content: content,createdAt: createdAt,updatedAt: updatedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required int objectId,required String content,Value<DateTime> createdAt = const Value.absent(),Value<DateTime> updatedAt = const Value.absent(),})=> NotesCompanion.insert(id: id,objectId: objectId,content: content,createdAt: createdAt,updatedAt: updatedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$NotesTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note,BaseReferences<_$AppDatabase,$NotesTable,Note>),
    Note,
    PrefetchHooks Function()
    >;class $AppDatabaseManager {
final _$AppDatabase _db;
$AppDatabaseManager(this._db);
$$CategoriesTableTableManager get categories => $$CategoriesTableTableManager(_db, _db.categories);
$$HobbyObjectsTableTableManager get hobbyObjects => $$HobbyObjectsTableTableManager(_db, _db.hobbyObjects);
$$NotesTableTableManager get notes => $$NotesTableTableManager(_db, _db.notes);
}
