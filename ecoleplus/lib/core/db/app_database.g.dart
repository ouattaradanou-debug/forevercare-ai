// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class Schools extends Table with TableInfo<Schools, SchoolRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Schools(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _communeMeta = const VerificationMeta(
    'commune',
  );
  late final GeneratedColumn<String> commune = GeneratedColumn<String>(
    'commune',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _departementMeta = const VerificationMeta(
    'departement',
  );
  late final GeneratedColumn<String> departement = GeneratedColumn<String>(
    'departement',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _provinceMeta = const VerificationMeta(
    'province',
  );
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
    'province',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _schoolTypeMeta = const VerificationMeta(
    'schoolType',
  );
  late final GeneratedColumn<String> schoolType = GeneratedColumn<String>(
    'school_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'publique\'',
    defaultValue: const CustomExpression('\'publique\''),
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _directorNameMeta = const VerificationMeta(
    'directorName',
  );
  late final GeneratedColumn<String> directorName = GeneratedColumn<String>(
    'director_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _managesPrimaryMeta = const VerificationMeta(
    'managesPrimary',
  );
  late final GeneratedColumn<bool> managesPrimary = GeneratedColumn<bool>(
    'manages_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT TRUE',
    defaultValue: const CustomExpression('TRUE'),
  );
  static const VerificationMeta _gradingScaleMeta = const VerificationMeta(
    'gradingScale',
  );
  late final GeneratedColumn<double> gradingScale = GeneratedColumn<double>(
    'grading_scale',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 10',
    defaultValue: const CustomExpression('10'),
  );
  static const VerificationMeta _showRaceReligionMeta = const VerificationMeta(
    'showRaceReligion',
  );
  late final GeneratedColumn<bool> showRaceReligion = GeneratedColumn<bool>(
    'show_race_religion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _absentRuleMeta = const VerificationMeta(
    'absentRule',
  );
  late final GeneratedColumn<String> absentRule = GeneratedColumn<String>(
    'absent_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'non_compte\'',
    defaultValue: const CustomExpression('\'non_compte\''),
  );
  static const VerificationMeta _currentSchoolYearIdMeta =
      const VerificationMeta('currentSchoolYearId');
  late final GeneratedColumn<String> currentSchoolYearId =
      GeneratedColumn<String>(
        'current_school_year_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    commune,
    departement,
    province,
    region,
    schoolType,
    phone,
    email,
    address,
    directorName,
    managesPrimary,
    gradingScale,
    showRaceReligion,
    absentRule,
    currentSchoolYearId,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schools';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('commune')) {
      context.handle(
        _communeMeta,
        commune.isAcceptableOrUnknown(data['commune']!, _communeMeta),
      );
    }
    if (data.containsKey('departement')) {
      context.handle(
        _departementMeta,
        departement.isAcceptableOrUnknown(
          data['departement']!,
          _departementMeta,
        ),
      );
    }
    if (data.containsKey('province')) {
      context.handle(
        _provinceMeta,
        province.isAcceptableOrUnknown(data['province']!, _provinceMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('school_type')) {
      context.handle(
        _schoolTypeMeta,
        schoolType.isAcceptableOrUnknown(data['school_type']!, _schoolTypeMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('director_name')) {
      context.handle(
        _directorNameMeta,
        directorName.isAcceptableOrUnknown(
          data['director_name']!,
          _directorNameMeta,
        ),
      );
    }
    if (data.containsKey('manages_primary')) {
      context.handle(
        _managesPrimaryMeta,
        managesPrimary.isAcceptableOrUnknown(
          data['manages_primary']!,
          _managesPrimaryMeta,
        ),
      );
    }
    if (data.containsKey('grading_scale')) {
      context.handle(
        _gradingScaleMeta,
        gradingScale.isAcceptableOrUnknown(
          data['grading_scale']!,
          _gradingScaleMeta,
        ),
      );
    }
    if (data.containsKey('show_race_religion')) {
      context.handle(
        _showRaceReligionMeta,
        showRaceReligion.isAcceptableOrUnknown(
          data['show_race_religion']!,
          _showRaceReligionMeta,
        ),
      );
    }
    if (data.containsKey('absent_rule')) {
      context.handle(
        _absentRuleMeta,
        absentRule.isAcceptableOrUnknown(data['absent_rule']!, _absentRuleMeta),
      );
    }
    if (data.containsKey('current_school_year_id')) {
      context.handle(
        _currentSchoolYearIdMeta,
        currentSchoolYearId.isAcceptableOrUnknown(
          data['current_school_year_id']!,
          _currentSchoolYearIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchoolRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      commune: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commune'],
      ),
      departement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departement'],
      ),
      province: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}province'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      schoolType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_type'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      directorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}director_name'],
      ),
      managesPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}manages_primary'],
      )!,
      gradingScale: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grading_scale'],
      )!,
      showRaceReligion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}show_race_religion'],
      )!,
      absentRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}absent_rule'],
      )!,
      currentSchoolYearId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_school_year_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Schools createAlias(String alias) {
    return Schools(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SchoolRow extends DataClass implements Insertable<SchoolRow> {
  final String id;
  final String name;
  final String? commune;
  final String? departement;
  final String? province;
  final String? region;
  final String schoolType;
  final String? phone;
  final String? email;
  final String? address;
  final String? directorName;
  final bool managesPrimary;
  final double gradingScale;
  final bool showRaceReligion;
  final String absentRule;
  final String? currentSchoolYearId;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const SchoolRow({
    required this.id,
    required this.name,
    this.commune,
    this.departement,
    this.province,
    this.region,
    required this.schoolType,
    this.phone,
    this.email,
    this.address,
    this.directorName,
    required this.managesPrimary,
    required this.gradingScale,
    required this.showRaceReligion,
    required this.absentRule,
    this.currentSchoolYearId,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || commune != null) {
      map['commune'] = Variable<String>(commune);
    }
    if (!nullToAbsent || departement != null) {
      map['departement'] = Variable<String>(departement);
    }
    if (!nullToAbsent || province != null) {
      map['province'] = Variable<String>(province);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    map['school_type'] = Variable<String>(schoolType);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || directorName != null) {
      map['director_name'] = Variable<String>(directorName);
    }
    map['manages_primary'] = Variable<bool>(managesPrimary);
    map['grading_scale'] = Variable<double>(gradingScale);
    map['show_race_religion'] = Variable<bool>(showRaceReligion);
    map['absent_rule'] = Variable<String>(absentRule);
    if (!nullToAbsent || currentSchoolYearId != null) {
      map['current_school_year_id'] = Variable<String>(currentSchoolYearId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  SchoolsCompanion toCompanion(bool nullToAbsent) {
    return SchoolsCompanion(
      id: Value(id),
      name: Value(name),
      commune: commune == null && nullToAbsent
          ? const Value.absent()
          : Value(commune),
      departement: departement == null && nullToAbsent
          ? const Value.absent()
          : Value(departement),
      province: province == null && nullToAbsent
          ? const Value.absent()
          : Value(province),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      schoolType: Value(schoolType),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      directorName: directorName == null && nullToAbsent
          ? const Value.absent()
          : Value(directorName),
      managesPrimary: Value(managesPrimary),
      gradingScale: Value(gradingScale),
      showRaceReligion: Value(showRaceReligion),
      absentRule: Value(absentRule),
      currentSchoolYearId: currentSchoolYearId == null && nullToAbsent
          ? const Value.absent()
          : Value(currentSchoolYearId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SchoolRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      commune: serializer.fromJson<String?>(json['commune']),
      departement: serializer.fromJson<String?>(json['departement']),
      province: serializer.fromJson<String?>(json['province']),
      region: serializer.fromJson<String?>(json['region']),
      schoolType: serializer.fromJson<String>(json['school_type']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      directorName: serializer.fromJson<String?>(json['director_name']),
      managesPrimary: serializer.fromJson<bool>(json['manages_primary']),
      gradingScale: serializer.fromJson<double>(json['grading_scale']),
      showRaceReligion: serializer.fromJson<bool>(json['show_race_religion']),
      absentRule: serializer.fromJson<String>(json['absent_rule']),
      currentSchoolYearId: serializer.fromJson<String?>(
        json['current_school_year_id'],
      ),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'commune': serializer.toJson<String?>(commune),
      'departement': serializer.toJson<String?>(departement),
      'province': serializer.toJson<String?>(province),
      'region': serializer.toJson<String?>(region),
      'school_type': serializer.toJson<String>(schoolType),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'director_name': serializer.toJson<String?>(directorName),
      'manages_primary': serializer.toJson<bool>(managesPrimary),
      'grading_scale': serializer.toJson<double>(gradingScale),
      'show_race_religion': serializer.toJson<bool>(showRaceReligion),
      'absent_rule': serializer.toJson<String>(absentRule),
      'current_school_year_id': serializer.toJson<String?>(currentSchoolYearId),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  SchoolRow copyWith({
    String? id,
    String? name,
    Value<String?> commune = const Value.absent(),
    Value<String?> departement = const Value.absent(),
    Value<String?> province = const Value.absent(),
    Value<String?> region = const Value.absent(),
    String? schoolType,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> directorName = const Value.absent(),
    bool? managesPrimary,
    double? gradingScale,
    bool? showRaceReligion,
    String? absentRule,
    Value<String?> currentSchoolYearId = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => SchoolRow(
    id: id ?? this.id,
    name: name ?? this.name,
    commune: commune.present ? commune.value : this.commune,
    departement: departement.present ? departement.value : this.departement,
    province: province.present ? province.value : this.province,
    region: region.present ? region.value : this.region,
    schoolType: schoolType ?? this.schoolType,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    directorName: directorName.present ? directorName.value : this.directorName,
    managesPrimary: managesPrimary ?? this.managesPrimary,
    gradingScale: gradingScale ?? this.gradingScale,
    showRaceReligion: showRaceReligion ?? this.showRaceReligion,
    absentRule: absentRule ?? this.absentRule,
    currentSchoolYearId: currentSchoolYearId.present
        ? currentSchoolYearId.value
        : this.currentSchoolYearId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SchoolRow copyWithCompanion(SchoolsCompanion data) {
    return SchoolRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      commune: data.commune.present ? data.commune.value : this.commune,
      departement: data.departement.present
          ? data.departement.value
          : this.departement,
      province: data.province.present ? data.province.value : this.province,
      region: data.region.present ? data.region.value : this.region,
      schoolType: data.schoolType.present
          ? data.schoolType.value
          : this.schoolType,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      directorName: data.directorName.present
          ? data.directorName.value
          : this.directorName,
      managesPrimary: data.managesPrimary.present
          ? data.managesPrimary.value
          : this.managesPrimary,
      gradingScale: data.gradingScale.present
          ? data.gradingScale.value
          : this.gradingScale,
      showRaceReligion: data.showRaceReligion.present
          ? data.showRaceReligion.value
          : this.showRaceReligion,
      absentRule: data.absentRule.present
          ? data.absentRule.value
          : this.absentRule,
      currentSchoolYearId: data.currentSchoolYearId.present
          ? data.currentSchoolYearId.value
          : this.currentSchoolYearId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('commune: $commune, ')
          ..write('departement: $departement, ')
          ..write('province: $province, ')
          ..write('region: $region, ')
          ..write('schoolType: $schoolType, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('directorName: $directorName, ')
          ..write('managesPrimary: $managesPrimary, ')
          ..write('gradingScale: $gradingScale, ')
          ..write('showRaceReligion: $showRaceReligion, ')
          ..write('absentRule: $absentRule, ')
          ..write('currentSchoolYearId: $currentSchoolYearId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    commune,
    departement,
    province,
    region,
    schoolType,
    phone,
    email,
    address,
    directorName,
    managesPrimary,
    gradingScale,
    showRaceReligion,
    absentRule,
    currentSchoolYearId,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.commune == this.commune &&
          other.departement == this.departement &&
          other.province == this.province &&
          other.region == this.region &&
          other.schoolType == this.schoolType &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.directorName == this.directorName &&
          other.managesPrimary == this.managesPrimary &&
          other.gradingScale == this.gradingScale &&
          other.showRaceReligion == this.showRaceReligion &&
          other.absentRule == this.absentRule &&
          other.currentSchoolYearId == this.currentSchoolYearId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class SchoolsCompanion extends UpdateCompanion<SchoolRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> commune;
  final Value<String?> departement;
  final Value<String?> province;
  final Value<String?> region;
  final Value<String> schoolType;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> directorName;
  final Value<bool> managesPrimary;
  final Value<double> gradingScale;
  final Value<bool> showRaceReligion;
  final Value<String> absentRule;
  final Value<String?> currentSchoolYearId;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const SchoolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.commune = const Value.absent(),
    this.departement = const Value.absent(),
    this.province = const Value.absent(),
    this.region = const Value.absent(),
    this.schoolType = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.directorName = const Value.absent(),
    this.managesPrimary = const Value.absent(),
    this.gradingScale = const Value.absent(),
    this.showRaceReligion = const Value.absent(),
    this.absentRule = const Value.absent(),
    this.currentSchoolYearId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolsCompanion.insert({
    required String id,
    required String name,
    this.commune = const Value.absent(),
    this.departement = const Value.absent(),
    this.province = const Value.absent(),
    this.region = const Value.absent(),
    this.schoolType = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.directorName = const Value.absent(),
    this.managesPrimary = const Value.absent(),
    this.gradingScale = const Value.absent(),
    this.showRaceReligion = const Value.absent(),
    this.absentRule = const Value.absent(),
    this.currentSchoolYearId = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<SchoolRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? commune,
    Expression<String>? departement,
    Expression<String>? province,
    Expression<String>? region,
    Expression<String>? schoolType,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? directorName,
    Expression<bool>? managesPrimary,
    Expression<double>? gradingScale,
    Expression<bool>? showRaceReligion,
    Expression<String>? absentRule,
    Expression<String>? currentSchoolYearId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (commune != null) 'commune': commune,
      if (departement != null) 'departement': departement,
      if (province != null) 'province': province,
      if (region != null) 'region': region,
      if (schoolType != null) 'school_type': schoolType,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (directorName != null) 'director_name': directorName,
      if (managesPrimary != null) 'manages_primary': managesPrimary,
      if (gradingScale != null) 'grading_scale': gradingScale,
      if (showRaceReligion != null) 'show_race_religion': showRaceReligion,
      if (absentRule != null) 'absent_rule': absentRule,
      if (currentSchoolYearId != null)
        'current_school_year_id': currentSchoolYearId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? commune,
    Value<String?>? departement,
    Value<String?>? province,
    Value<String?>? region,
    Value<String>? schoolType,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? directorName,
    Value<bool>? managesPrimary,
    Value<double>? gradingScale,
    Value<bool>? showRaceReligion,
    Value<String>? absentRule,
    Value<String?>? currentSchoolYearId,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return SchoolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      commune: commune ?? this.commune,
      departement: departement ?? this.departement,
      province: province ?? this.province,
      region: region ?? this.region,
      schoolType: schoolType ?? this.schoolType,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      directorName: directorName ?? this.directorName,
      managesPrimary: managesPrimary ?? this.managesPrimary,
      gradingScale: gradingScale ?? this.gradingScale,
      showRaceReligion: showRaceReligion ?? this.showRaceReligion,
      absentRule: absentRule ?? this.absentRule,
      currentSchoolYearId: currentSchoolYearId ?? this.currentSchoolYearId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (commune.present) {
      map['commune'] = Variable<String>(commune.value);
    }
    if (departement.present) {
      map['departement'] = Variable<String>(departement.value);
    }
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (schoolType.present) {
      map['school_type'] = Variable<String>(schoolType.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (directorName.present) {
      map['director_name'] = Variable<String>(directorName.value);
    }
    if (managesPrimary.present) {
      map['manages_primary'] = Variable<bool>(managesPrimary.value);
    }
    if (gradingScale.present) {
      map['grading_scale'] = Variable<double>(gradingScale.value);
    }
    if (showRaceReligion.present) {
      map['show_race_religion'] = Variable<bool>(showRaceReligion.value);
    }
    if (absentRule.present) {
      map['absent_rule'] = Variable<String>(absentRule.value);
    }
    if (currentSchoolYearId.present) {
      map['current_school_year_id'] = Variable<String>(
        currentSchoolYearId.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('commune: $commune, ')
          ..write('departement: $departement, ')
          ..write('province: $province, ')
          ..write('region: $region, ')
          ..write('schoolType: $schoolType, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('directorName: $directorName, ')
          ..write('managesPrimary: $managesPrimary, ')
          ..write('gradingScale: $gradingScale, ')
          ..write('showRaceReligion: $showRaceReligion, ')
          ..write('absentRule: $absentRule, ')
          ..write('currentSchoolYearId: $currentSchoolYearId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SchoolYears extends Table with TableInfo<SchoolYears, SchoolYearRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SchoolYears(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  late final GeneratedColumn<String> startsOn = GeneratedColumn<String>(
    'starts_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  late final GeneratedColumn<String> endsOn = GeneratedColumn<String>(
    'ends_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    label,
    startsOn,
    endsOn,
    archivedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'school_years';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolYearRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchoolYearRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolYearRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}starts_on'],
      ),
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ends_on'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archived_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  SchoolYears createAlias(String alias) {
    return SchoolYears(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SchoolYearRow extends DataClass implements Insertable<SchoolYearRow> {
  final String id;
  final String schoolId;
  final String label;
  final String? startsOn;
  final String? endsOn;
  final String? archivedAt;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const SchoolYearRow({
    required this.id,
    required this.schoolId,
    required this.label,
    this.startsOn,
    this.endsOn,
    this.archivedAt,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || startsOn != null) {
      map['starts_on'] = Variable<String>(startsOn);
    }
    if (!nullToAbsent || endsOn != null) {
      map['ends_on'] = Variable<String>(endsOn);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(archivedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  SchoolYearsCompanion toCompanion(bool nullToAbsent) {
    return SchoolYearsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      label: Value(label),
      startsOn: startsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(startsOn),
      endsOn: endsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endsOn),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SchoolYearRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolYearRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      label: serializer.fromJson<String>(json['label']),
      startsOn: serializer.fromJson<String?>(json['starts_on']),
      endsOn: serializer.fromJson<String?>(json['ends_on']),
      archivedAt: serializer.fromJson<String?>(json['archived_at']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'label': serializer.toJson<String>(label),
      'starts_on': serializer.toJson<String?>(startsOn),
      'ends_on': serializer.toJson<String?>(endsOn),
      'archived_at': serializer.toJson<String?>(archivedAt),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  SchoolYearRow copyWith({
    String? id,
    String? schoolId,
    String? label,
    Value<String?> startsOn = const Value.absent(),
    Value<String?> endsOn = const Value.absent(),
    Value<String?> archivedAt = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => SchoolYearRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    label: label ?? this.label,
    startsOn: startsOn.present ? startsOn.value : this.startsOn,
    endsOn: endsOn.present ? endsOn.value : this.endsOn,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SchoolYearRow copyWithCompanion(SchoolYearsCompanion data) {
    return SchoolYearRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      label: data.label.present ? data.label.value : this.label,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolYearRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('label: $label, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    label,
    startsOn,
    endsOn,
    archivedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolYearRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.label == this.label &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.archivedAt == this.archivedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class SchoolYearsCompanion extends UpdateCompanion<SchoolYearRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> label;
  final Value<String?> startsOn;
  final Value<String?> endsOn;
  final Value<String?> archivedAt;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const SchoolYearsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.label = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolYearsCompanion.insert({
    required String id,
    required String schoolId,
    required String label,
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       label = Value(label),
       updatedAt = Value(updatedAt);
  static Insertable<SchoolYearRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? label,
    Expression<String>? startsOn,
    Expression<String>? endsOn,
    Expression<String>? archivedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (label != null) 'label': label,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolYearsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? label,
    Value<String?>? startsOn,
    Value<String?>? endsOn,
    Value<String?>? archivedAt,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return SchoolYearsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      label: label ?? this.label,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<String>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<String>(endsOn.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolYearsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('label: $label, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AdminHeaders extends Table with TableInfo<AdminHeaders, AdminHeaderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AdminHeaders(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _schoolYearIdMeta = const VerificationMeta(
    'schoolYearId',
  );
  late final GeneratedColumn<String> schoolYearId = GeneratedColumn<String>(
    'school_year_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'BURKINA FASO\'',
    defaultValue: const CustomExpression('\'BURKINA FASO\''),
  );
  static const VerificationMeta _mottoMeta = const VerificationMeta('motto');
  late final GeneratedColumn<String> motto = GeneratedColumn<String>(
    'motto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _ministryMeta = const VerificationMeta(
    'ministry',
  );
  late final GeneratedColumn<String> ministry = GeneratedColumn<String>(
    'ministry',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _regionalDirectionMeta = const VerificationMeta(
    'regionalDirection',
  );
  late final GeneratedColumn<String> regionalDirection =
      GeneratedColumn<String>(
        'regional_direction',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _provincialDirectionMeta =
      const VerificationMeta('provincialDirection');
  late final GeneratedColumn<String> provincialDirection =
      GeneratedColumn<String>(
        'provincial_direction',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _cebMeta = const VerificationMeta('ceb');
  late final GeneratedColumn<String> ceb = GeneratedColumn<String>(
    'ceb',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _provinceMeta = const VerificationMeta(
    'province',
  );
  late final GeneratedColumn<String> province = GeneratedColumn<String>(
    'province',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _departementMeta = const VerificationMeta(
    'departement',
  );
  late final GeneratedColumn<String> departement = GeneratedColumn<String>(
    'departement',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _communeMeta = const VerificationMeta(
    'commune',
  );
  late final GeneratedColumn<String> commune = GeneratedColumn<String>(
    'commune',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _schoolLabelMeta = const VerificationMeta(
    'schoolLabel',
  );
  late final GeneratedColumn<String> schoolLabel = GeneratedColumn<String>(
    'school_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _emblemPathMeta = const VerificationMeta(
    'emblemPath',
  );
  late final GeneratedColumn<String> emblemPath = GeneratedColumn<String>(
    'emblem_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    schoolYearId,
    country,
    motto,
    ministry,
    region,
    regionalDirection,
    provincialDirection,
    ceb,
    province,
    departement,
    commune,
    schoolLabel,
    emblemPath,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'admin_headers';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdminHeaderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('school_year_id')) {
      context.handle(
        _schoolYearIdMeta,
        schoolYearId.isAcceptableOrUnknown(
          data['school_year_id']!,
          _schoolYearIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schoolYearIdMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('motto')) {
      context.handle(
        _mottoMeta,
        motto.isAcceptableOrUnknown(data['motto']!, _mottoMeta),
      );
    }
    if (data.containsKey('ministry')) {
      context.handle(
        _ministryMeta,
        ministry.isAcceptableOrUnknown(data['ministry']!, _ministryMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('regional_direction')) {
      context.handle(
        _regionalDirectionMeta,
        regionalDirection.isAcceptableOrUnknown(
          data['regional_direction']!,
          _regionalDirectionMeta,
        ),
      );
    }
    if (data.containsKey('provincial_direction')) {
      context.handle(
        _provincialDirectionMeta,
        provincialDirection.isAcceptableOrUnknown(
          data['provincial_direction']!,
          _provincialDirectionMeta,
        ),
      );
    }
    if (data.containsKey('ceb')) {
      context.handle(
        _cebMeta,
        ceb.isAcceptableOrUnknown(data['ceb']!, _cebMeta),
      );
    }
    if (data.containsKey('province')) {
      context.handle(
        _provinceMeta,
        province.isAcceptableOrUnknown(data['province']!, _provinceMeta),
      );
    }
    if (data.containsKey('departement')) {
      context.handle(
        _departementMeta,
        departement.isAcceptableOrUnknown(
          data['departement']!,
          _departementMeta,
        ),
      );
    }
    if (data.containsKey('commune')) {
      context.handle(
        _communeMeta,
        commune.isAcceptableOrUnknown(data['commune']!, _communeMeta),
      );
    }
    if (data.containsKey('school_label')) {
      context.handle(
        _schoolLabelMeta,
        schoolLabel.isAcceptableOrUnknown(
          data['school_label']!,
          _schoolLabelMeta,
        ),
      );
    }
    if (data.containsKey('emblem_path')) {
      context.handle(
        _emblemPathMeta,
        emblemPath.isAcceptableOrUnknown(data['emblem_path']!, _emblemPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdminHeaderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdminHeaderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      schoolYearId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_year_id'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      motto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motto'],
      ),
      ministry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ministry'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      regionalDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regional_direction'],
      ),
      provincialDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provincial_direction'],
      ),
      ceb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ceb'],
      ),
      province: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}province'],
      ),
      departement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departement'],
      ),
      commune: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commune'],
      ),
      schoolLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_label'],
      ),
      emblemPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emblem_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  AdminHeaders createAlias(String alias) {
    return AdminHeaders(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AdminHeaderRow extends DataClass implements Insertable<AdminHeaderRow> {
  final String id;
  final String schoolId;
  final String schoolYearId;
  final String country;
  final String? motto;
  final String? ministry;
  final String? region;
  final String? regionalDirection;
  final String? provincialDirection;
  final String? ceb;
  final String? province;
  final String? departement;
  final String? commune;
  final String? schoolLabel;
  final String? emblemPath;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const AdminHeaderRow({
    required this.id,
    required this.schoolId,
    required this.schoolYearId,
    required this.country,
    this.motto,
    this.ministry,
    this.region,
    this.regionalDirection,
    this.provincialDirection,
    this.ceb,
    this.province,
    this.departement,
    this.commune,
    this.schoolLabel,
    this.emblemPath,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['school_year_id'] = Variable<String>(schoolYearId);
    map['country'] = Variable<String>(country);
    if (!nullToAbsent || motto != null) {
      map['motto'] = Variable<String>(motto);
    }
    if (!nullToAbsent || ministry != null) {
      map['ministry'] = Variable<String>(ministry);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || regionalDirection != null) {
      map['regional_direction'] = Variable<String>(regionalDirection);
    }
    if (!nullToAbsent || provincialDirection != null) {
      map['provincial_direction'] = Variable<String>(provincialDirection);
    }
    if (!nullToAbsent || ceb != null) {
      map['ceb'] = Variable<String>(ceb);
    }
    if (!nullToAbsent || province != null) {
      map['province'] = Variable<String>(province);
    }
    if (!nullToAbsent || departement != null) {
      map['departement'] = Variable<String>(departement);
    }
    if (!nullToAbsent || commune != null) {
      map['commune'] = Variable<String>(commune);
    }
    if (!nullToAbsent || schoolLabel != null) {
      map['school_label'] = Variable<String>(schoolLabel);
    }
    if (!nullToAbsent || emblemPath != null) {
      map['emblem_path'] = Variable<String>(emblemPath);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  AdminHeadersCompanion toCompanion(bool nullToAbsent) {
    return AdminHeadersCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      schoolYearId: Value(schoolYearId),
      country: Value(country),
      motto: motto == null && nullToAbsent
          ? const Value.absent()
          : Value(motto),
      ministry: ministry == null && nullToAbsent
          ? const Value.absent()
          : Value(ministry),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      regionalDirection: regionalDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(regionalDirection),
      provincialDirection: provincialDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(provincialDirection),
      ceb: ceb == null && nullToAbsent ? const Value.absent() : Value(ceb),
      province: province == null && nullToAbsent
          ? const Value.absent()
          : Value(province),
      departement: departement == null && nullToAbsent
          ? const Value.absent()
          : Value(departement),
      commune: commune == null && nullToAbsent
          ? const Value.absent()
          : Value(commune),
      schoolLabel: schoolLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(schoolLabel),
      emblemPath: emblemPath == null && nullToAbsent
          ? const Value.absent()
          : Value(emblemPath),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory AdminHeaderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdminHeaderRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      schoolYearId: serializer.fromJson<String>(json['school_year_id']),
      country: serializer.fromJson<String>(json['country']),
      motto: serializer.fromJson<String?>(json['motto']),
      ministry: serializer.fromJson<String?>(json['ministry']),
      region: serializer.fromJson<String?>(json['region']),
      regionalDirection: serializer.fromJson<String?>(
        json['regional_direction'],
      ),
      provincialDirection: serializer.fromJson<String?>(
        json['provincial_direction'],
      ),
      ceb: serializer.fromJson<String?>(json['ceb']),
      province: serializer.fromJson<String?>(json['province']),
      departement: serializer.fromJson<String?>(json['departement']),
      commune: serializer.fromJson<String?>(json['commune']),
      schoolLabel: serializer.fromJson<String?>(json['school_label']),
      emblemPath: serializer.fromJson<String?>(json['emblem_path']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'school_year_id': serializer.toJson<String>(schoolYearId),
      'country': serializer.toJson<String>(country),
      'motto': serializer.toJson<String?>(motto),
      'ministry': serializer.toJson<String?>(ministry),
      'region': serializer.toJson<String?>(region),
      'regional_direction': serializer.toJson<String?>(regionalDirection),
      'provincial_direction': serializer.toJson<String?>(provincialDirection),
      'ceb': serializer.toJson<String?>(ceb),
      'province': serializer.toJson<String?>(province),
      'departement': serializer.toJson<String?>(departement),
      'commune': serializer.toJson<String?>(commune),
      'school_label': serializer.toJson<String?>(schoolLabel),
      'emblem_path': serializer.toJson<String?>(emblemPath),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  AdminHeaderRow copyWith({
    String? id,
    String? schoolId,
    String? schoolYearId,
    String? country,
    Value<String?> motto = const Value.absent(),
    Value<String?> ministry = const Value.absent(),
    Value<String?> region = const Value.absent(),
    Value<String?> regionalDirection = const Value.absent(),
    Value<String?> provincialDirection = const Value.absent(),
    Value<String?> ceb = const Value.absent(),
    Value<String?> province = const Value.absent(),
    Value<String?> departement = const Value.absent(),
    Value<String?> commune = const Value.absent(),
    Value<String?> schoolLabel = const Value.absent(),
    Value<String?> emblemPath = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => AdminHeaderRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    schoolYearId: schoolYearId ?? this.schoolYearId,
    country: country ?? this.country,
    motto: motto.present ? motto.value : this.motto,
    ministry: ministry.present ? ministry.value : this.ministry,
    region: region.present ? region.value : this.region,
    regionalDirection: regionalDirection.present
        ? regionalDirection.value
        : this.regionalDirection,
    provincialDirection: provincialDirection.present
        ? provincialDirection.value
        : this.provincialDirection,
    ceb: ceb.present ? ceb.value : this.ceb,
    province: province.present ? province.value : this.province,
    departement: departement.present ? departement.value : this.departement,
    commune: commune.present ? commune.value : this.commune,
    schoolLabel: schoolLabel.present ? schoolLabel.value : this.schoolLabel,
    emblemPath: emblemPath.present ? emblemPath.value : this.emblemPath,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  AdminHeaderRow copyWithCompanion(AdminHeadersCompanion data) {
    return AdminHeaderRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      schoolYearId: data.schoolYearId.present
          ? data.schoolYearId.value
          : this.schoolYearId,
      country: data.country.present ? data.country.value : this.country,
      motto: data.motto.present ? data.motto.value : this.motto,
      ministry: data.ministry.present ? data.ministry.value : this.ministry,
      region: data.region.present ? data.region.value : this.region,
      regionalDirection: data.regionalDirection.present
          ? data.regionalDirection.value
          : this.regionalDirection,
      provincialDirection: data.provincialDirection.present
          ? data.provincialDirection.value
          : this.provincialDirection,
      ceb: data.ceb.present ? data.ceb.value : this.ceb,
      province: data.province.present ? data.province.value : this.province,
      departement: data.departement.present
          ? data.departement.value
          : this.departement,
      commune: data.commune.present ? data.commune.value : this.commune,
      schoolLabel: data.schoolLabel.present
          ? data.schoolLabel.value
          : this.schoolLabel,
      emblemPath: data.emblemPath.present
          ? data.emblemPath.value
          : this.emblemPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdminHeaderRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('schoolYearId: $schoolYearId, ')
          ..write('country: $country, ')
          ..write('motto: $motto, ')
          ..write('ministry: $ministry, ')
          ..write('region: $region, ')
          ..write('regionalDirection: $regionalDirection, ')
          ..write('provincialDirection: $provincialDirection, ')
          ..write('ceb: $ceb, ')
          ..write('province: $province, ')
          ..write('departement: $departement, ')
          ..write('commune: $commune, ')
          ..write('schoolLabel: $schoolLabel, ')
          ..write('emblemPath: $emblemPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    schoolYearId,
    country,
    motto,
    ministry,
    region,
    regionalDirection,
    provincialDirection,
    ceb,
    province,
    departement,
    commune,
    schoolLabel,
    emblemPath,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdminHeaderRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.schoolYearId == this.schoolYearId &&
          other.country == this.country &&
          other.motto == this.motto &&
          other.ministry == this.ministry &&
          other.region == this.region &&
          other.regionalDirection == this.regionalDirection &&
          other.provincialDirection == this.provincialDirection &&
          other.ceb == this.ceb &&
          other.province == this.province &&
          other.departement == this.departement &&
          other.commune == this.commune &&
          other.schoolLabel == this.schoolLabel &&
          other.emblemPath == this.emblemPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class AdminHeadersCompanion extends UpdateCompanion<AdminHeaderRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> schoolYearId;
  final Value<String> country;
  final Value<String?> motto;
  final Value<String?> ministry;
  final Value<String?> region;
  final Value<String?> regionalDirection;
  final Value<String?> provincialDirection;
  final Value<String?> ceb;
  final Value<String?> province;
  final Value<String?> departement;
  final Value<String?> commune;
  final Value<String?> schoolLabel;
  final Value<String?> emblemPath;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const AdminHeadersCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.schoolYearId = const Value.absent(),
    this.country = const Value.absent(),
    this.motto = const Value.absent(),
    this.ministry = const Value.absent(),
    this.region = const Value.absent(),
    this.regionalDirection = const Value.absent(),
    this.provincialDirection = const Value.absent(),
    this.ceb = const Value.absent(),
    this.province = const Value.absent(),
    this.departement = const Value.absent(),
    this.commune = const Value.absent(),
    this.schoolLabel = const Value.absent(),
    this.emblemPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdminHeadersCompanion.insert({
    required String id,
    required String schoolId,
    required String schoolYearId,
    this.country = const Value.absent(),
    this.motto = const Value.absent(),
    this.ministry = const Value.absent(),
    this.region = const Value.absent(),
    this.regionalDirection = const Value.absent(),
    this.provincialDirection = const Value.absent(),
    this.ceb = const Value.absent(),
    this.province = const Value.absent(),
    this.departement = const Value.absent(),
    this.commune = const Value.absent(),
    this.schoolLabel = const Value.absent(),
    this.emblemPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       schoolYearId = Value(schoolYearId),
       updatedAt = Value(updatedAt);
  static Insertable<AdminHeaderRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? schoolYearId,
    Expression<String>? country,
    Expression<String>? motto,
    Expression<String>? ministry,
    Expression<String>? region,
    Expression<String>? regionalDirection,
    Expression<String>? provincialDirection,
    Expression<String>? ceb,
    Expression<String>? province,
    Expression<String>? departement,
    Expression<String>? commune,
    Expression<String>? schoolLabel,
    Expression<String>? emblemPath,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (schoolYearId != null) 'school_year_id': schoolYearId,
      if (country != null) 'country': country,
      if (motto != null) 'motto': motto,
      if (ministry != null) 'ministry': ministry,
      if (region != null) 'region': region,
      if (regionalDirection != null) 'regional_direction': regionalDirection,
      if (provincialDirection != null)
        'provincial_direction': provincialDirection,
      if (ceb != null) 'ceb': ceb,
      if (province != null) 'province': province,
      if (departement != null) 'departement': departement,
      if (commune != null) 'commune': commune,
      if (schoolLabel != null) 'school_label': schoolLabel,
      if (emblemPath != null) 'emblem_path': emblemPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdminHeadersCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? schoolYearId,
    Value<String>? country,
    Value<String?>? motto,
    Value<String?>? ministry,
    Value<String?>? region,
    Value<String?>? regionalDirection,
    Value<String?>? provincialDirection,
    Value<String?>? ceb,
    Value<String?>? province,
    Value<String?>? departement,
    Value<String?>? commune,
    Value<String?>? schoolLabel,
    Value<String?>? emblemPath,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return AdminHeadersCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      schoolYearId: schoolYearId ?? this.schoolYearId,
      country: country ?? this.country,
      motto: motto ?? this.motto,
      ministry: ministry ?? this.ministry,
      region: region ?? this.region,
      regionalDirection: regionalDirection ?? this.regionalDirection,
      provincialDirection: provincialDirection ?? this.provincialDirection,
      ceb: ceb ?? this.ceb,
      province: province ?? this.province,
      departement: departement ?? this.departement,
      commune: commune ?? this.commune,
      schoolLabel: schoolLabel ?? this.schoolLabel,
      emblemPath: emblemPath ?? this.emblemPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (schoolYearId.present) {
      map['school_year_id'] = Variable<String>(schoolYearId.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (motto.present) {
      map['motto'] = Variable<String>(motto.value);
    }
    if (ministry.present) {
      map['ministry'] = Variable<String>(ministry.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (regionalDirection.present) {
      map['regional_direction'] = Variable<String>(regionalDirection.value);
    }
    if (provincialDirection.present) {
      map['provincial_direction'] = Variable<String>(provincialDirection.value);
    }
    if (ceb.present) {
      map['ceb'] = Variable<String>(ceb.value);
    }
    if (province.present) {
      map['province'] = Variable<String>(province.value);
    }
    if (departement.present) {
      map['departement'] = Variable<String>(departement.value);
    }
    if (commune.present) {
      map['commune'] = Variable<String>(commune.value);
    }
    if (schoolLabel.present) {
      map['school_label'] = Variable<String>(schoolLabel.value);
    }
    if (emblemPath.present) {
      map['emblem_path'] = Variable<String>(emblemPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdminHeadersCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('schoolYearId: $schoolYearId, ')
          ..write('country: $country, ')
          ..write('motto: $motto, ')
          ..write('ministry: $ministry, ')
          ..write('region: $region, ')
          ..write('regionalDirection: $regionalDirection, ')
          ..write('provincialDirection: $provincialDirection, ')
          ..write('ceb: $ceb, ')
          ..write('province: $province, ')
          ..write('departement: $departement, ')
          ..write('commune: $commune, ')
          ..write('schoolLabel: $schoolLabel, ')
          ..write('emblemPath: $emblemPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ModulesCatalog extends Table
    with TableInfo<ModulesCatalog, ModuleCatalogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ModulesCatalog(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _dependsOnMeta = const VerificationMeta(
    'dependsOn',
  );
  late final GeneratedColumn<String> dependsOn = GeneratedColumn<String>(
    'depends_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    label,
    description,
    dependsOn,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'modules_catalog';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModuleCatalogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('depends_on')) {
      context.handle(
        _dependsOnMeta,
        dependsOn.isAcceptableOrUnknown(data['depends_on']!, _dependsOnMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ModuleCatalogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModuleCatalogRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      dependsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depends_on'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  ModulesCatalog createAlias(String alias) {
    return ModulesCatalog(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ModuleCatalogRow extends DataClass
    implements Insertable<ModuleCatalogRow> {
  final String key;
  final String label;
  final String description;
  final String? dependsOn;
  final int sortOrder;
  const ModuleCatalogRow({
    required this.key,
    required this.label,
    required this.description,
    this.dependsOn,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['label'] = Variable<String>(label);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || dependsOn != null) {
      map['depends_on'] = Variable<String>(dependsOn);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ModulesCatalogCompanion toCompanion(bool nullToAbsent) {
    return ModulesCatalogCompanion(
      key: Value(key),
      label: Value(label),
      description: Value(description),
      dependsOn: dependsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dependsOn),
      sortOrder: Value(sortOrder),
    );
  }

  factory ModuleCatalogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModuleCatalogRow(
      key: serializer.fromJson<String>(json['key']),
      label: serializer.fromJson<String>(json['label']),
      description: serializer.fromJson<String>(json['description']),
      dependsOn: serializer.fromJson<String?>(json['depends_on']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'label': serializer.toJson<String>(label),
      'description': serializer.toJson<String>(description),
      'depends_on': serializer.toJson<String?>(dependsOn),
      'sort_order': serializer.toJson<int>(sortOrder),
    };
  }

  ModuleCatalogRow copyWith({
    String? key,
    String? label,
    String? description,
    Value<String?> dependsOn = const Value.absent(),
    int? sortOrder,
  }) => ModuleCatalogRow(
    key: key ?? this.key,
    label: label ?? this.label,
    description: description ?? this.description,
    dependsOn: dependsOn.present ? dependsOn.value : this.dependsOn,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ModuleCatalogRow copyWithCompanion(ModulesCatalogCompanion data) {
    return ModuleCatalogRow(
      key: data.key.present ? data.key.value : this.key,
      label: data.label.present ? data.label.value : this.label,
      description: data.description.present
          ? data.description.value
          : this.description,
      dependsOn: data.dependsOn.present ? data.dependsOn.value : this.dependsOn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModuleCatalogRow(')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('dependsOn: $dependsOn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, label, description, dependsOn, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModuleCatalogRow &&
          other.key == this.key &&
          other.label == this.label &&
          other.description == this.description &&
          other.dependsOn == this.dependsOn &&
          other.sortOrder == this.sortOrder);
}

class ModulesCatalogCompanion extends UpdateCompanion<ModuleCatalogRow> {
  final Value<String> key;
  final Value<String> label;
  final Value<String> description;
  final Value<String?> dependsOn;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ModulesCatalogCompanion({
    this.key = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.dependsOn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModulesCatalogCompanion.insert({
    required String key,
    required String label,
    required String description,
    this.dependsOn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       label = Value(label),
       description = Value(description);
  static Insertable<ModuleCatalogRow> custom({
    Expression<String>? key,
    Expression<String>? label,
    Expression<String>? description,
    Expression<String>? dependsOn,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (dependsOn != null) 'depends_on': dependsOn,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModulesCatalogCompanion copyWith({
    Value<String>? key,
    Value<String>? label,
    Value<String>? description,
    Value<String?>? dependsOn,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ModulesCatalogCompanion(
      key: key ?? this.key,
      label: label ?? this.label,
      description: description ?? this.description,
      dependsOn: dependsOn ?? this.dependsOn,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dependsOn.present) {
      map['depends_on'] = Variable<String>(dependsOn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModulesCatalogCompanion(')
          ..write('key: $key, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('dependsOn: $dependsOn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SchoolModules extends Table
    with TableInfo<SchoolModules, SchoolModuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SchoolModules(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _moduleKeyMeta = const VerificationMeta(
    'moduleKey',
  );
  late final GeneratedColumn<String> moduleKey = GeneratedColumn<String>(
    'module_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    schoolId,
    moduleKey,
    enabled,
    createdAt,
    updatedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'school_modules';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchoolModuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('module_key')) {
      context.handle(
        _moduleKeyMeta,
        moduleKey.isAcceptableOrUnknown(data['module_key']!, _moduleKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleKeyMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {schoolId, moduleKey};
  @override
  SchoolModuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchoolModuleRow(
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      moduleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module_key'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  SchoolModules createAlias(String alias) {
    return SchoolModules(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(school_id, module_key)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class SchoolModuleRow extends DataClass implements Insertable<SchoolModuleRow> {
  final String schoolId;
  final String moduleKey;
  final bool enabled;
  final String? createdAt;
  final String updatedAt;
  final String? syncedAt;
  const SchoolModuleRow({
    required this.schoolId,
    required this.moduleKey,
    required this.enabled,
    this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['school_id'] = Variable<String>(schoolId);
    map['module_key'] = Variable<String>(moduleKey);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  SchoolModulesCompanion toCompanion(bool nullToAbsent) {
    return SchoolModulesCompanion(
      schoolId: Value(schoolId),
      moduleKey: Value(moduleKey),
      enabled: Value(enabled),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SchoolModuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchoolModuleRow(
      schoolId: serializer.fromJson<String>(json['school_id']),
      moduleKey: serializer.fromJson<String>(json['module_key']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'school_id': serializer.toJson<String>(schoolId),
      'module_key': serializer.toJson<String>(moduleKey),
      'enabled': serializer.toJson<bool>(enabled),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  SchoolModuleRow copyWith({
    String? schoolId,
    String? moduleKey,
    bool? enabled,
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> syncedAt = const Value.absent(),
  }) => SchoolModuleRow(
    schoolId: schoolId ?? this.schoolId,
    moduleKey: moduleKey ?? this.moduleKey,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SchoolModuleRow copyWithCompanion(SchoolModulesCompanion data) {
    return SchoolModuleRow(
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      moduleKey: data.moduleKey.present ? data.moduleKey.value : this.moduleKey,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchoolModuleRow(')
          ..write('schoolId: $schoolId, ')
          ..write('moduleKey: $moduleKey, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(schoolId, moduleKey, enabled, createdAt, updatedAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchoolModuleRow &&
          other.schoolId == this.schoolId &&
          other.moduleKey == this.moduleKey &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncedAt == this.syncedAt);
}

class SchoolModulesCompanion extends UpdateCompanion<SchoolModuleRow> {
  final Value<String> schoolId;
  final Value<String> moduleKey;
  final Value<bool> enabled;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const SchoolModulesCompanion({
    this.schoolId = const Value.absent(),
    this.moduleKey = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolModulesCompanion.insert({
    required String schoolId,
    required String moduleKey,
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : schoolId = Value(schoolId),
       moduleKey = Value(moduleKey),
       updatedAt = Value(updatedAt);
  static Insertable<SchoolModuleRow> custom({
    Expression<String>? schoolId,
    Expression<String>? moduleKey,
    Expression<bool>? enabled,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (schoolId != null) 'school_id': schoolId,
      if (moduleKey != null) 'module_key': moduleKey,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolModulesCompanion copyWith({
    Value<String>? schoolId,
    Value<String>? moduleKey,
    Value<bool>? enabled,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return SchoolModulesCompanion(
      schoolId: schoolId ?? this.schoolId,
      moduleKey: moduleKey ?? this.moduleKey,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (moduleKey.present) {
      map['module_key'] = Variable<String>(moduleKey.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolModulesCompanion(')
          ..write('schoolId: $schoolId, ')
          ..write('moduleKey: $moduleKey, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Memberships extends Table with TableInfo<Memberships, MembershipRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Memberships(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT TRUE',
    defaultValue: const CustomExpression('TRUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    userId,
    role,
    teacherId,
    displayName,
    phone,
    active,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<MembershipRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MembershipRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MembershipRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Memberships createAlias(String alias) {
    return Memberships(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class MembershipRow extends DataClass implements Insertable<MembershipRow> {
  final String id;
  final String schoolId;
  final String userId;
  final String role;
  final String? teacherId;
  final String displayName;
  final String? phone;
  final bool active;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const MembershipRow({
    required this.id,
    required this.schoolId,
    required this.userId,
    required this.role,
    this.teacherId,
    required this.displayName,
    this.phone,
    required this.active,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<String>(teacherId);
    }
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  MembershipsCompanion toCompanion(bool nullToAbsent) {
    return MembershipsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      userId: Value(userId),
      role: Value(role),
      teacherId: teacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherId),
      displayName: Value(displayName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      active: Value(active),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory MembershipRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MembershipRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      userId: serializer.fromJson<String>(json['user_id']),
      role: serializer.fromJson<String>(json['role']),
      teacherId: serializer.fromJson<String?>(json['teacher_id']),
      displayName: serializer.fromJson<String>(json['display_name']),
      phone: serializer.fromJson<String?>(json['phone']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'user_id': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'teacher_id': serializer.toJson<String?>(teacherId),
      'display_name': serializer.toJson<String>(displayName),
      'phone': serializer.toJson<String?>(phone),
      'active': serializer.toJson<bool>(active),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  MembershipRow copyWith({
    String? id,
    String? schoolId,
    String? userId,
    String? role,
    Value<String?> teacherId = const Value.absent(),
    String? displayName,
    Value<String?> phone = const Value.absent(),
    bool? active,
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => MembershipRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    teacherId: teacherId.present ? teacherId.value : this.teacherId,
    displayName: displayName ?? this.displayName,
    phone: phone.present ? phone.value : this.phone,
    active: active ?? this.active,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  MembershipRow copyWithCompanion(MembershipsCompanion data) {
    return MembershipRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      phone: data.phone.present ? data.phone.value : this.phone,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MembershipRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('teacherId: $teacherId, ')
          ..write('displayName: $displayName, ')
          ..write('phone: $phone, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    userId,
    role,
    teacherId,
    displayName,
    phone,
    active,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MembershipRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.teacherId == this.teacherId &&
          other.displayName == this.displayName &&
          other.phone == this.phone &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class MembershipsCompanion extends UpdateCompanion<MembershipRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> userId;
  final Value<String> role;
  final Value<String?> teacherId;
  final Value<String> displayName;
  final Value<String?> phone;
  final Value<bool> active;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const MembershipsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.phone = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembershipsCompanion.insert({
    required String id,
    required String schoolId,
    required String userId,
    required String role,
    this.teacherId = const Value.absent(),
    required String displayName,
    this.phone = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       userId = Value(userId),
       role = Value(role),
       displayName = Value(displayName),
       updatedAt = Value(updatedAt);
  static Insertable<MembershipRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<String>? teacherId,
    Expression<String>? displayName,
    Expression<String>? phone,
    Expression<bool>? active,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (teacherId != null) 'teacher_id': teacherId,
      if (displayName != null) 'display_name': displayName,
      if (phone != null) 'phone': phone,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembershipsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? userId,
    Value<String>? role,
    Value<String?>? teacherId,
    Value<String>? displayName,
    Value<String?>? phone,
    Value<bool>? active,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return MembershipsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      teacherId: teacherId ?? this.teacherId,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembershipsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('teacherId: $teacherId, ')
          ..write('displayName: $displayName, ')
          ..write('phone: $phone, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DelegatePermissions extends Table
    with TableInfo<DelegatePermissions, DelegatePermissionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DelegatePermissions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _membershipIdMeta = const VerificationMeta(
    'membershipId',
  );
  late final GeneratedColumn<String> membershipId = GeneratedColumn<String>(
    'membership_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _permissionKeyMeta = const VerificationMeta(
    'permissionKey',
  );
  late final GeneratedColumn<String> permissionKey = GeneratedColumn<String>(
    'permission_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    membershipId,
    permissionKey,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delegate_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DelegatePermissionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('membership_id')) {
      context.handle(
        _membershipIdMeta,
        membershipId.isAcceptableOrUnknown(
          data['membership_id']!,
          _membershipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_membershipIdMeta);
    }
    if (data.containsKey('permission_key')) {
      context.handle(
        _permissionKeyMeta,
        permissionKey.isAcceptableOrUnknown(
          data['permission_key']!,
          _permissionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_permissionKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DelegatePermissionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DelegatePermissionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      membershipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}membership_id'],
      )!,
      permissionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  DelegatePermissions createAlias(String alias) {
    return DelegatePermissions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class DelegatePermissionRow extends DataClass
    implements Insertable<DelegatePermissionRow> {
  final String id;
  final String schoolId;
  final String membershipId;
  final String permissionKey;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const DelegatePermissionRow({
    required this.id,
    required this.schoolId,
    required this.membershipId,
    required this.permissionKey,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['membership_id'] = Variable<String>(membershipId);
    map['permission_key'] = Variable<String>(permissionKey);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  DelegatePermissionsCompanion toCompanion(bool nullToAbsent) {
    return DelegatePermissionsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      membershipId: Value(membershipId),
      permissionKey: Value(permissionKey),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory DelegatePermissionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DelegatePermissionRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      membershipId: serializer.fromJson<String>(json['membership_id']),
      permissionKey: serializer.fromJson<String>(json['permission_key']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'membership_id': serializer.toJson<String>(membershipId),
      'permission_key': serializer.toJson<String>(permissionKey),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  DelegatePermissionRow copyWith({
    String? id,
    String? schoolId,
    String? membershipId,
    String? permissionKey,
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => DelegatePermissionRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    membershipId: membershipId ?? this.membershipId,
    permissionKey: permissionKey ?? this.permissionKey,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  DelegatePermissionRow copyWithCompanion(DelegatePermissionsCompanion data) {
    return DelegatePermissionRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      membershipId: data.membershipId.present
          ? data.membershipId.value
          : this.membershipId,
      permissionKey: data.permissionKey.present
          ? data.permissionKey.value
          : this.permissionKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DelegatePermissionRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('membershipId: $membershipId, ')
          ..write('permissionKey: $permissionKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    membershipId,
    permissionKey,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DelegatePermissionRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.membershipId == this.membershipId &&
          other.permissionKey == this.permissionKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class DelegatePermissionsCompanion
    extends UpdateCompanion<DelegatePermissionRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> membershipId;
  final Value<String> permissionKey;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const DelegatePermissionsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.membershipId = const Value.absent(),
    this.permissionKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DelegatePermissionsCompanion.insert({
    required String id,
    required String schoolId,
    required String membershipId,
    required String permissionKey,
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       membershipId = Value(membershipId),
       permissionKey = Value(permissionKey),
       updatedAt = Value(updatedAt);
  static Insertable<DelegatePermissionRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? membershipId,
    Expression<String>? permissionKey,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (membershipId != null) 'membership_id': membershipId,
      if (permissionKey != null) 'permission_key': permissionKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DelegatePermissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? membershipId,
    Value<String>? permissionKey,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return DelegatePermissionsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      membershipId: membershipId ?? this.membershipId,
      permissionKey: permissionKey ?? this.permissionKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (membershipId.present) {
      map['membership_id'] = Variable<String>(membershipId.value);
    }
    if (permissionKey.present) {
      map['permission_key'] = Variable<String>(permissionKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DelegatePermissionsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('membershipId: $membershipId, ')
          ..write('permissionKey: $permissionKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Devices extends Table with TableInfo<Devices, DeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Devices(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _seriesCodeMeta = const VerificationMeta(
    'seriesCode',
  );
  late final GeneratedColumn<String> seriesCode = GeneratedColumn<String>(
    'series_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  late final GeneratedColumn<String> lastSeenAt = GeneratedColumn<String>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  late final GeneratedColumn<String> lastSyncAt = GeneratedColumn<String>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _pendingCountMeta = const VerificationMeta(
    'pendingCount',
  );
  late final GeneratedColumn<int> pendingCount = GeneratedColumn<int>(
    'pending_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  late final GeneratedColumn<String> revokedAt = GeneratedColumn<String>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    userId,
    label,
    seriesCode,
    lastSeenAt,
    lastSyncAt,
    pendingCount,
    appVersion,
    revokedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('series_code')) {
      context.handle(
        _seriesCodeMeta,
        seriesCode.isAcceptableOrUnknown(data['series_code']!, _seriesCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesCodeMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('pending_count')) {
      context.handle(
        _pendingCountMeta,
        pendingCount.isAcceptableOrUnknown(
          data['pending_count']!,
          _pendingCountMeta,
        ),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      seriesCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_code'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_seen_at'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_at'],
      ),
      pendingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_count'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      ),
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revoked_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Devices createAlias(String alias) {
    return Devices(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class DeviceRow extends DataClass implements Insertable<DeviceRow> {
  final String id;
  final String schoolId;
  final String? userId;
  final String label;
  final String seriesCode;
  final String? lastSeenAt;
  final String? lastSyncAt;
  final int pendingCount;
  final String? appVersion;
  final String? revokedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const DeviceRow({
    required this.id,
    required this.schoolId,
    this.userId,
    required this.label,
    required this.seriesCode,
    this.lastSeenAt,
    this.lastSyncAt,
    required this.pendingCount,
    this.appVersion,
    this.revokedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['label'] = Variable<String>(label);
    map['series_code'] = Variable<String>(seriesCode);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<String>(lastSeenAt);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<String>(lastSyncAt);
    }
    map['pending_count'] = Variable<int>(pendingCount);
    if (!nullToAbsent || appVersion != null) {
      map['app_version'] = Variable<String>(appVersion);
    }
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<String>(revokedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      label: Value(label),
      seriesCode: Value(seriesCode),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      pendingCount: Value(pendingCount),
      appVersion: appVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(appVersion),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory DeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      userId: serializer.fromJson<String?>(json['user_id']),
      label: serializer.fromJson<String>(json['label']),
      seriesCode: serializer.fromJson<String>(json['series_code']),
      lastSeenAt: serializer.fromJson<String?>(json['last_seen_at']),
      lastSyncAt: serializer.fromJson<String?>(json['last_sync_at']),
      pendingCount: serializer.fromJson<int>(json['pending_count']),
      appVersion: serializer.fromJson<String?>(json['app_version']),
      revokedAt: serializer.fromJson<String?>(json['revoked_at']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String?>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'user_id': serializer.toJson<String?>(userId),
      'label': serializer.toJson<String>(label),
      'series_code': serializer.toJson<String>(seriesCode),
      'last_seen_at': serializer.toJson<String?>(lastSeenAt),
      'last_sync_at': serializer.toJson<String?>(lastSyncAt),
      'pending_count': serializer.toJson<int>(pendingCount),
      'app_version': serializer.toJson<String?>(appVersion),
      'revoked_at': serializer.toJson<String?>(revokedAt),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String?>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  DeviceRow copyWith({
    String? id,
    String? schoolId,
    Value<String?> userId = const Value.absent(),
    String? label,
    String? seriesCode,
    Value<String?> lastSeenAt = const Value.absent(),
    Value<String?> lastSyncAt = const Value.absent(),
    int? pendingCount,
    Value<String?> appVersion = const Value.absent(),
    Value<String?> revokedAt = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => DeviceRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    userId: userId.present ? userId.value : this.userId,
    label: label ?? this.label,
    seriesCode: seriesCode ?? this.seriesCode,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    pendingCount: pendingCount ?? this.pendingCount,
    appVersion: appVersion.present ? appVersion.value : this.appVersion,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  DeviceRow copyWithCompanion(DevicesCompanion data) {
    return DeviceRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      userId: data.userId.present ? data.userId.value : this.userId,
      label: data.label.present ? data.label.value : this.label,
      seriesCode: data.seriesCode.present
          ? data.seriesCode.value
          : this.seriesCode,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      pendingCount: data.pendingCount.present
          ? data.pendingCount.value
          : this.pendingCount,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('seriesCode: $seriesCode, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('pendingCount: $pendingCount, ')
          ..write('appVersion: $appVersion, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    userId,
    label,
    seriesCode,
    lastSeenAt,
    lastSyncAt,
    pendingCount,
    appVersion,
    revokedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.userId == this.userId &&
          other.label == this.label &&
          other.seriesCode == this.seriesCode &&
          other.lastSeenAt == this.lastSeenAt &&
          other.lastSyncAt == this.lastSyncAt &&
          other.pendingCount == this.pendingCount &&
          other.appVersion == this.appVersion &&
          other.revokedAt == this.revokedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class DevicesCompanion extends UpdateCompanion<DeviceRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String?> userId;
  final Value<String> label;
  final Value<String> seriesCode;
  final Value<String?> lastSeenAt;
  final Value<String?> lastSyncAt;
  final Value<int> pendingCount;
  final Value<String?> appVersion;
  final Value<String?> revokedAt;
  final Value<String?> createdAt;
  final Value<String?> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.userId = const Value.absent(),
    this.label = const Value.absent(),
    this.seriesCode = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.pendingCount = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesCompanion.insert({
    required String id,
    required String schoolId,
    this.userId = const Value.absent(),
    required String label,
    required String seriesCode,
    this.lastSeenAt = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.pendingCount = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       label = Value(label),
       seriesCode = Value(seriesCode);
  static Insertable<DeviceRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? userId,
    Expression<String>? label,
    Expression<String>? seriesCode,
    Expression<String>? lastSeenAt,
    Expression<String>? lastSyncAt,
    Expression<int>? pendingCount,
    Expression<String>? appVersion,
    Expression<String>? revokedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (userId != null) 'user_id': userId,
      if (label != null) 'label': label,
      if (seriesCode != null) 'series_code': seriesCode,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (pendingCount != null) 'pending_count': pendingCount,
      if (appVersion != null) 'app_version': appVersion,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String?>? userId,
    Value<String>? label,
    Value<String>? seriesCode,
    Value<String?>? lastSeenAt,
    Value<String?>? lastSyncAt,
    Value<int>? pendingCount,
    Value<String?>? appVersion,
    Value<String?>? revokedAt,
    Value<String?>? createdAt,
    Value<String?>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      seriesCode: seriesCode ?? this.seriesCode,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      pendingCount: pendingCount ?? this.pendingCount,
      appVersion: appVersion ?? this.appVersion,
      revokedAt: revokedAt ?? this.revokedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (seriesCode.present) {
      map['series_code'] = Variable<String>(seriesCode.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<String>(lastSeenAt.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<String>(lastSyncAt.value);
    }
    if (pendingCount.present) {
      map['pending_count'] = Variable<int>(pendingCount.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<String>(revokedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('userId: $userId, ')
          ..write('label: $label, ')
          ..write('seriesCode: $seriesCode, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('pendingCount: $pendingCount, ')
          ..write('appVersion: $appVersion, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AuditLog extends Table with TableInfo<AuditLog, AuditRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AuditLog(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  late final GeneratedColumn<String> occurredAt = GeneratedColumn<String>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _affectedTableMeta = const VerificationMeta(
    'affectedTable',
  );
  late final GeneratedColumn<String> affectedTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    occurredAt,
    actorId,
    action,
    affectedTable,
    rowId,
    details,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('table_name')) {
      context.handle(
        _affectedTableMeta,
        affectedTable.isAcceptableOrUnknown(
          data['table_name']!,
          _affectedTableMeta,
        ),
      );
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurred_at'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      affectedTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      ),
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      ),
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  AuditLog createAlias(String alias) {
    return AuditLog(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AuditRow extends DataClass implements Insertable<AuditRow> {
  final String id;
  final String schoolId;
  final String occurredAt;
  final String? actorId;
  final String action;
  final String? affectedTable;
  final String? rowId;
  final String? details;
  final String? syncedAt;
  const AuditRow({
    required this.id,
    required this.schoolId,
    required this.occurredAt,
    this.actorId,
    required this.action,
    this.affectedTable,
    this.rowId,
    this.details,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['occurred_at'] = Variable<String>(occurredAt);
    if (!nullToAbsent || actorId != null) {
      map['actor_id'] = Variable<String>(actorId);
    }
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || affectedTable != null) {
      map['table_name'] = Variable<String>(affectedTable);
    }
    if (!nullToAbsent || rowId != null) {
      map['row_id'] = Variable<String>(rowId);
    }
    if (!nullToAbsent || details != null) {
      map['details'] = Variable<String>(details);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      occurredAt: Value(occurredAt),
      actorId: actorId == null && nullToAbsent
          ? const Value.absent()
          : Value(actorId),
      action: Value(action),
      affectedTable: affectedTable == null && nullToAbsent
          ? const Value.absent()
          : Value(affectedTable),
      rowId: rowId == null && nullToAbsent
          ? const Value.absent()
          : Value(rowId),
      details: details == null && nullToAbsent
          ? const Value.absent()
          : Value(details),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory AuditRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      occurredAt: serializer.fromJson<String>(json['occurred_at']),
      actorId: serializer.fromJson<String?>(json['actor_id']),
      action: serializer.fromJson<String>(json['action']),
      affectedTable: serializer.fromJson<String?>(json['table_name']),
      rowId: serializer.fromJson<String?>(json['row_id']),
      details: serializer.fromJson<String?>(json['details']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'occurred_at': serializer.toJson<String>(occurredAt),
      'actor_id': serializer.toJson<String?>(actorId),
      'action': serializer.toJson<String>(action),
      'table_name': serializer.toJson<String?>(affectedTable),
      'row_id': serializer.toJson<String?>(rowId),
      'details': serializer.toJson<String?>(details),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  AuditRow copyWith({
    String? id,
    String? schoolId,
    String? occurredAt,
    Value<String?> actorId = const Value.absent(),
    String? action,
    Value<String?> affectedTable = const Value.absent(),
    Value<String?> rowId = const Value.absent(),
    Value<String?> details = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => AuditRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    occurredAt: occurredAt ?? this.occurredAt,
    actorId: actorId.present ? actorId.value : this.actorId,
    action: action ?? this.action,
    affectedTable: affectedTable.present
        ? affectedTable.value
        : this.affectedTable,
    rowId: rowId.present ? rowId.value : this.rowId,
    details: details.present ? details.value : this.details,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  AuditRow copyWithCompanion(AuditLogCompanion data) {
    return AuditRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      action: data.action.present ? data.action.value : this.action,
      affectedTable: data.affectedTable.present
          ? data.affectedTable.value
          : this.affectedTable,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      details: data.details.present ? data.details.value : this.details,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('actorId: $actorId, ')
          ..write('action: $action, ')
          ..write('affectedTable: $affectedTable, ')
          ..write('rowId: $rowId, ')
          ..write('details: $details, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    occurredAt,
    actorId,
    action,
    affectedTable,
    rowId,
    details,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.occurredAt == this.occurredAt &&
          other.actorId == this.actorId &&
          other.action == this.action &&
          other.affectedTable == this.affectedTable &&
          other.rowId == this.rowId &&
          other.details == this.details &&
          other.syncedAt == this.syncedAt);
}

class AuditLogCompanion extends UpdateCompanion<AuditRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> occurredAt;
  final Value<String?> actorId;
  final Value<String> action;
  final Value<String?> affectedTable;
  final Value<String?> rowId;
  final Value<String?> details;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.actorId = const Value.absent(),
    this.action = const Value.absent(),
    this.affectedTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.details = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogCompanion.insert({
    required String id,
    required String schoolId,
    required String occurredAt,
    this.actorId = const Value.absent(),
    required String action,
    this.affectedTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.details = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       occurredAt = Value(occurredAt),
       action = Value(action);
  static Insertable<AuditRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? occurredAt,
    Expression<String>? actorId,
    Expression<String>? action,
    Expression<String>? affectedTable,
    Expression<String>? rowId,
    Expression<String>? details,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (actorId != null) 'actor_id': actorId,
      if (action != null) 'action': action,
      if (affectedTable != null) 'table_name': affectedTable,
      if (rowId != null) 'row_id': rowId,
      if (details != null) 'details': details,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? occurredAt,
    Value<String?>? actorId,
    Value<String>? action,
    Value<String?>? affectedTable,
    Value<String?>? rowId,
    Value<String?>? details,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return AuditLogCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      occurredAt: occurredAt ?? this.occurredAt,
      actorId: actorId ?? this.actorId,
      action: action ?? this.action,
      affectedTable: affectedTable ?? this.affectedTable,
      rowId: rowId ?? this.rowId,
      details: details ?? this.details,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<String>(occurredAt.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (affectedTable.present) {
      map['table_name'] = Variable<String>(affectedTable.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('actorId: $actorId, ')
          ..write('action: $action, ')
          ..write('affectedTable: $affectedTable, ')
          ..write('rowId: $rowId, ')
          ..write('details: $details, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Levels extends Table with TableInfo<Levels, LevelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Levels(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _cycleMeta = const VerificationMeta('cycle');
  late final GeneratedColumn<String> cycle = GeneratedColumn<String>(
    'cycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [code, cycle, label, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'levels';
  @override
  VerificationContext validateIntegrity(
    Insertable<LevelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('cycle')) {
      context.handle(
        _cycleMeta,
        cycle.isAcceptableOrUnknown(data['cycle']!, _cycleMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  LevelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LevelRow(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      cycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cycle'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  Levels createAlias(String alias) {
    return Levels(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class LevelRow extends DataClass implements Insertable<LevelRow> {
  final String code;
  final String cycle;
  final String label;
  final int sortOrder;
  const LevelRow({
    required this.code,
    required this.cycle,
    required this.label,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['cycle'] = Variable<String>(cycle);
    map['label'] = Variable<String>(label);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LevelsCompanion toCompanion(bool nullToAbsent) {
    return LevelsCompanion(
      code: Value(code),
      cycle: Value(cycle),
      label: Value(label),
      sortOrder: Value(sortOrder),
    );
  }

  factory LevelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LevelRow(
      code: serializer.fromJson<String>(json['code']),
      cycle: serializer.fromJson<String>(json['cycle']),
      label: serializer.fromJson<String>(json['label']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'cycle': serializer.toJson<String>(cycle),
      'label': serializer.toJson<String>(label),
      'sort_order': serializer.toJson<int>(sortOrder),
    };
  }

  LevelRow copyWith({
    String? code,
    String? cycle,
    String? label,
    int? sortOrder,
  }) => LevelRow(
    code: code ?? this.code,
    cycle: cycle ?? this.cycle,
    label: label ?? this.label,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LevelRow copyWithCompanion(LevelsCompanion data) {
    return LevelRow(
      code: data.code.present ? data.code.value : this.code,
      cycle: data.cycle.present ? data.cycle.value : this.cycle,
      label: data.label.present ? data.label.value : this.label,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LevelRow(')
          ..write('code: $code, ')
          ..write('cycle: $cycle, ')
          ..write('label: $label, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(code, cycle, label, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LevelRow &&
          other.code == this.code &&
          other.cycle == this.cycle &&
          other.label == this.label &&
          other.sortOrder == this.sortOrder);
}

class LevelsCompanion extends UpdateCompanion<LevelRow> {
  final Value<String> code;
  final Value<String> cycle;
  final Value<String> label;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const LevelsCompanion({
    this.code = const Value.absent(),
    this.cycle = const Value.absent(),
    this.label = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LevelsCompanion.insert({
    required String code,
    required String cycle,
    required String label,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       cycle = Value(cycle),
       label = Value(label),
       sortOrder = Value(sortOrder);
  static Insertable<LevelRow> custom({
    Expression<String>? code,
    Expression<String>? cycle,
    Expression<String>? label,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (cycle != null) 'cycle': cycle,
      if (label != null) 'label': label,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LevelsCompanion copyWith({
    Value<String>? code,
    Value<String>? cycle,
    Value<String>? label,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return LevelsCompanion(
      code: code ?? this.code,
      cycle: cycle ?? this.cycle,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (cycle.present) {
      map['cycle'] = Variable<String>(cycle.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LevelsCompanion(')
          ..write('code: $code, ')
          ..write('cycle: $cycle, ')
          ..write('label: $label, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Teachers extends Table with TableInfo<Teachers, TeacherRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Teachers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _firstNamesMeta = const VerificationMeta(
    'firstNames',
  );
  late final GeneratedColumn<String> firstNames = GeneratedColumn<String>(
    'first_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _matriculeMeta = const VerificationMeta(
    'matricule',
  );
  late final GeneratedColumn<String> matricule = GeneratedColumn<String>(
    'matricule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _birthPlaceMeta = const VerificationMeta(
    'birthPlace',
  );
  late final GeneratedColumn<String> birthPlace = GeneratedColumn<String>(
    'birth_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _emploiMeta = const VerificationMeta('emploi');
  late final GeneratedColumn<String> emploi = GeneratedColumn<String>(
    'emploi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _categorieMeta = const VerificationMeta(
    'categorie',
  );
  late final GeneratedColumn<String> categorie = GeneratedColumn<String>(
    'categorie',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _echelonMeta = const VerificationMeta(
    'echelon',
  );
  late final GeneratedColumn<String> echelon = GeneratedColumn<String>(
    'echelon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _tenureStatusMeta = const VerificationMeta(
    'tenureStatus',
  );
  late final GeneratedColumn<String> tenureStatus = GeneratedColumn<String>(
    'tenure_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'actif\'',
    defaultValue: const CustomExpression('\'actif\''),
  );
  static const VerificationMeta _communeNominationDateMeta =
      const VerificationMeta('communeNominationDate');
  late final GeneratedColumn<String> communeNominationDate =
      GeneratedColumn<String>(
        'commune_nomination_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _firstTeachingNominationDateMeta =
      const VerificationMeta('firstTeachingNominationDate');
  late final GeneratedColumn<String> firstTeachingNominationDate =
      GeneratedColumn<String>(
        'first_teaching_nomination_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _pupilSchoolNameMeta = const VerificationMeta(
    'pupilSchoolName',
  );
  late final GeneratedColumn<String> pupilSchoolName = GeneratedColumn<String>(
    'pupil_school_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _pupilSchoolEntryDateMeta =
      const VerificationMeta('pupilSchoolEntryDate');
  late final GeneratedColumn<String> pupilSchoolEntryDate =
      GeneratedColumn<String>(
        'pupil_school_entry_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _pupilSchoolExitDateMeta =
      const VerificationMeta('pupilSchoolExitDate');
  late final GeneratedColumn<String> pupilSchoolExitDate =
      GeneratedColumn<String>(
        'pupil_school_exit_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _seniorityGeneralFromMeta =
      const VerificationMeta('seniorityGeneralFrom');
  late final GeneratedColumn<String> seniorityGeneralFrom =
      GeneratedColumn<String>(
        'seniority_general_from',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _seniorityEmploiFromMeta =
      const VerificationMeta('seniorityEmploiFrom');
  late final GeneratedColumn<String> seniorityEmploiFrom =
      GeneratedColumn<String>(
        'seniority_emploi_from',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _seniorityRegionFromMeta =
      const VerificationMeta('seniorityRegionFrom');
  late final GeneratedColumn<String> seniorityRegionFrom =
      GeneratedColumn<String>(
        'seniority_region_from',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _seniorityFonctionFromMeta =
      const VerificationMeta('seniorityFonctionFrom');
  late final GeneratedColumn<String> seniorityFonctionFrom =
      GeneratedColumn<String>(
        'seniority_fonction_from',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _communeCessationDateMeta =
      const VerificationMeta('communeCessationDate');
  late final GeneratedColumn<String> communeCessationDate =
      GeneratedColumn<String>(
        'commune_cessation_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _newPostMeta = const VerificationMeta(
    'newPost',
  );
  late final GeneratedColumn<String> newPost = GeneratedColumn<String>(
    'new_post',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    lastName,
    firstNames,
    sex,
    matricule,
    phone,
    birthDate,
    birthPlace,
    emploi,
    categorie,
    echelon,
    tenureStatus,
    status,
    communeNominationDate,
    firstTeachingNominationDate,
    pupilSchoolName,
    pupilSchoolEntryDate,
    pupilSchoolExitDate,
    seniorityGeneralFrom,
    seniorityEmploiFrom,
    seniorityRegionFrom,
    seniorityFonctionFrom,
    communeCessationDate,
    newPost,
    observations,
    archivedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teachers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeacherRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('first_names')) {
      context.handle(
        _firstNamesMeta,
        firstNames.isAcceptableOrUnknown(data['first_names']!, _firstNamesMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNamesMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('matricule')) {
      context.handle(
        _matriculeMeta,
        matricule.isAcceptableOrUnknown(data['matricule']!, _matriculeMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('birth_place')) {
      context.handle(
        _birthPlaceMeta,
        birthPlace.isAcceptableOrUnknown(data['birth_place']!, _birthPlaceMeta),
      );
    }
    if (data.containsKey('emploi')) {
      context.handle(
        _emploiMeta,
        emploi.isAcceptableOrUnknown(data['emploi']!, _emploiMeta),
      );
    }
    if (data.containsKey('categorie')) {
      context.handle(
        _categorieMeta,
        categorie.isAcceptableOrUnknown(data['categorie']!, _categorieMeta),
      );
    }
    if (data.containsKey('echelon')) {
      context.handle(
        _echelonMeta,
        echelon.isAcceptableOrUnknown(data['echelon']!, _echelonMeta),
      );
    }
    if (data.containsKey('tenure_status')) {
      context.handle(
        _tenureStatusMeta,
        tenureStatus.isAcceptableOrUnknown(
          data['tenure_status']!,
          _tenureStatusMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('commune_nomination_date')) {
      context.handle(
        _communeNominationDateMeta,
        communeNominationDate.isAcceptableOrUnknown(
          data['commune_nomination_date']!,
          _communeNominationDateMeta,
        ),
      );
    }
    if (data.containsKey('first_teaching_nomination_date')) {
      context.handle(
        _firstTeachingNominationDateMeta,
        firstTeachingNominationDate.isAcceptableOrUnknown(
          data['first_teaching_nomination_date']!,
          _firstTeachingNominationDateMeta,
        ),
      );
    }
    if (data.containsKey('pupil_school_name')) {
      context.handle(
        _pupilSchoolNameMeta,
        pupilSchoolName.isAcceptableOrUnknown(
          data['pupil_school_name']!,
          _pupilSchoolNameMeta,
        ),
      );
    }
    if (data.containsKey('pupil_school_entry_date')) {
      context.handle(
        _pupilSchoolEntryDateMeta,
        pupilSchoolEntryDate.isAcceptableOrUnknown(
          data['pupil_school_entry_date']!,
          _pupilSchoolEntryDateMeta,
        ),
      );
    }
    if (data.containsKey('pupil_school_exit_date')) {
      context.handle(
        _pupilSchoolExitDateMeta,
        pupilSchoolExitDate.isAcceptableOrUnknown(
          data['pupil_school_exit_date']!,
          _pupilSchoolExitDateMeta,
        ),
      );
    }
    if (data.containsKey('seniority_general_from')) {
      context.handle(
        _seniorityGeneralFromMeta,
        seniorityGeneralFrom.isAcceptableOrUnknown(
          data['seniority_general_from']!,
          _seniorityGeneralFromMeta,
        ),
      );
    }
    if (data.containsKey('seniority_emploi_from')) {
      context.handle(
        _seniorityEmploiFromMeta,
        seniorityEmploiFrom.isAcceptableOrUnknown(
          data['seniority_emploi_from']!,
          _seniorityEmploiFromMeta,
        ),
      );
    }
    if (data.containsKey('seniority_region_from')) {
      context.handle(
        _seniorityRegionFromMeta,
        seniorityRegionFrom.isAcceptableOrUnknown(
          data['seniority_region_from']!,
          _seniorityRegionFromMeta,
        ),
      );
    }
    if (data.containsKey('seniority_fonction_from')) {
      context.handle(
        _seniorityFonctionFromMeta,
        seniorityFonctionFrom.isAcceptableOrUnknown(
          data['seniority_fonction_from']!,
          _seniorityFonctionFromMeta,
        ),
      );
    }
    if (data.containsKey('commune_cessation_date')) {
      context.handle(
        _communeCessationDateMeta,
        communeCessationDate.isAcceptableOrUnknown(
          data['commune_cessation_date']!,
          _communeCessationDateMeta,
        ),
      );
    }
    if (data.containsKey('new_post')) {
      context.handle(
        _newPostMeta,
        newPost.isAcceptableOrUnknown(data['new_post']!, _newPostMeta),
      );
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeacherRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      firstNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_names'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      ),
      matricule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}matricule'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_date'],
      ),
      birthPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_place'],
      ),
      emploi: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emploi'],
      ),
      categorie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categorie'],
      ),
      echelon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}echelon'],
      ),
      tenureStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenure_status'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      communeNominationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commune_nomination_date'],
      ),
      firstTeachingNominationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_teaching_nomination_date'],
      ),
      pupilSchoolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pupil_school_name'],
      ),
      pupilSchoolEntryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pupil_school_entry_date'],
      ),
      pupilSchoolExitDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pupil_school_exit_date'],
      ),
      seniorityGeneralFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seniority_general_from'],
      ),
      seniorityEmploiFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seniority_emploi_from'],
      ),
      seniorityRegionFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seniority_region_from'],
      ),
      seniorityFonctionFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seniority_fonction_from'],
      ),
      communeCessationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commune_cessation_date'],
      ),
      newPost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_post'],
      ),
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archived_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Teachers createAlias(String alias) {
    return Teachers(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TeacherRow extends DataClass implements Insertable<TeacherRow> {
  final String id;
  final String schoolId;
  final String lastName;
  final String firstNames;
  final String? sex;
  final String? matricule;
  final String? phone;
  final String? birthDate;
  final String? birthPlace;
  final String? emploi;
  final String? categorie;
  final String? echelon;
  final String? tenureStatus;
  final String status;
  final String? communeNominationDate;
  final String? firstTeachingNominationDate;
  final String? pupilSchoolName;
  final String? pupilSchoolEntryDate;
  final String? pupilSchoolExitDate;
  final String? seniorityGeneralFrom;
  final String? seniorityEmploiFrom;
  final String? seniorityRegionFrom;
  final String? seniorityFonctionFrom;
  final String? communeCessationDate;
  final String? newPost;
  final String? observations;
  final String? archivedAt;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const TeacherRow({
    required this.id,
    required this.schoolId,
    required this.lastName,
    required this.firstNames,
    this.sex,
    this.matricule,
    this.phone,
    this.birthDate,
    this.birthPlace,
    this.emploi,
    this.categorie,
    this.echelon,
    this.tenureStatus,
    required this.status,
    this.communeNominationDate,
    this.firstTeachingNominationDate,
    this.pupilSchoolName,
    this.pupilSchoolEntryDate,
    this.pupilSchoolExitDate,
    this.seniorityGeneralFrom,
    this.seniorityEmploiFrom,
    this.seniorityRegionFrom,
    this.seniorityFonctionFrom,
    this.communeCessationDate,
    this.newPost,
    this.observations,
    this.archivedAt,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['last_name'] = Variable<String>(lastName);
    map['first_names'] = Variable<String>(firstNames);
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || matricule != null) {
      map['matricule'] = Variable<String>(matricule);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(birthDate);
    }
    if (!nullToAbsent || birthPlace != null) {
      map['birth_place'] = Variable<String>(birthPlace);
    }
    if (!nullToAbsent || emploi != null) {
      map['emploi'] = Variable<String>(emploi);
    }
    if (!nullToAbsent || categorie != null) {
      map['categorie'] = Variable<String>(categorie);
    }
    if (!nullToAbsent || echelon != null) {
      map['echelon'] = Variable<String>(echelon);
    }
    if (!nullToAbsent || tenureStatus != null) {
      map['tenure_status'] = Variable<String>(tenureStatus);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || communeNominationDate != null) {
      map['commune_nomination_date'] = Variable<String>(communeNominationDate);
    }
    if (!nullToAbsent || firstTeachingNominationDate != null) {
      map['first_teaching_nomination_date'] = Variable<String>(
        firstTeachingNominationDate,
      );
    }
    if (!nullToAbsent || pupilSchoolName != null) {
      map['pupil_school_name'] = Variable<String>(pupilSchoolName);
    }
    if (!nullToAbsent || pupilSchoolEntryDate != null) {
      map['pupil_school_entry_date'] = Variable<String>(pupilSchoolEntryDate);
    }
    if (!nullToAbsent || pupilSchoolExitDate != null) {
      map['pupil_school_exit_date'] = Variable<String>(pupilSchoolExitDate);
    }
    if (!nullToAbsent || seniorityGeneralFrom != null) {
      map['seniority_general_from'] = Variable<String>(seniorityGeneralFrom);
    }
    if (!nullToAbsent || seniorityEmploiFrom != null) {
      map['seniority_emploi_from'] = Variable<String>(seniorityEmploiFrom);
    }
    if (!nullToAbsent || seniorityRegionFrom != null) {
      map['seniority_region_from'] = Variable<String>(seniorityRegionFrom);
    }
    if (!nullToAbsent || seniorityFonctionFrom != null) {
      map['seniority_fonction_from'] = Variable<String>(seniorityFonctionFrom);
    }
    if (!nullToAbsent || communeCessationDate != null) {
      map['commune_cessation_date'] = Variable<String>(communeCessationDate);
    }
    if (!nullToAbsent || newPost != null) {
      map['new_post'] = Variable<String>(newPost);
    }
    if (!nullToAbsent || observations != null) {
      map['observations'] = Variable<String>(observations);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(archivedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  TeachersCompanion toCompanion(bool nullToAbsent) {
    return TeachersCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      lastName: Value(lastName),
      firstNames: Value(firstNames),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      matricule: matricule == null && nullToAbsent
          ? const Value.absent()
          : Value(matricule),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      birthPlace: birthPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(birthPlace),
      emploi: emploi == null && nullToAbsent
          ? const Value.absent()
          : Value(emploi),
      categorie: categorie == null && nullToAbsent
          ? const Value.absent()
          : Value(categorie),
      echelon: echelon == null && nullToAbsent
          ? const Value.absent()
          : Value(echelon),
      tenureStatus: tenureStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(tenureStatus),
      status: Value(status),
      communeNominationDate: communeNominationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(communeNominationDate),
      firstTeachingNominationDate:
          firstTeachingNominationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(firstTeachingNominationDate),
      pupilSchoolName: pupilSchoolName == null && nullToAbsent
          ? const Value.absent()
          : Value(pupilSchoolName),
      pupilSchoolEntryDate: pupilSchoolEntryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(pupilSchoolEntryDate),
      pupilSchoolExitDate: pupilSchoolExitDate == null && nullToAbsent
          ? const Value.absent()
          : Value(pupilSchoolExitDate),
      seniorityGeneralFrom: seniorityGeneralFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(seniorityGeneralFrom),
      seniorityEmploiFrom: seniorityEmploiFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(seniorityEmploiFrom),
      seniorityRegionFrom: seniorityRegionFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(seniorityRegionFrom),
      seniorityFonctionFrom: seniorityFonctionFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(seniorityFonctionFrom),
      communeCessationDate: communeCessationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(communeCessationDate),
      newPost: newPost == null && nullToAbsent
          ? const Value.absent()
          : Value(newPost),
      observations: observations == null && nullToAbsent
          ? const Value.absent()
          : Value(observations),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory TeacherRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      lastName: serializer.fromJson<String>(json['last_name']),
      firstNames: serializer.fromJson<String>(json['first_names']),
      sex: serializer.fromJson<String?>(json['sex']),
      matricule: serializer.fromJson<String?>(json['matricule']),
      phone: serializer.fromJson<String?>(json['phone']),
      birthDate: serializer.fromJson<String?>(json['birth_date']),
      birthPlace: serializer.fromJson<String?>(json['birth_place']),
      emploi: serializer.fromJson<String?>(json['emploi']),
      categorie: serializer.fromJson<String?>(json['categorie']),
      echelon: serializer.fromJson<String?>(json['echelon']),
      tenureStatus: serializer.fromJson<String?>(json['tenure_status']),
      status: serializer.fromJson<String>(json['status']),
      communeNominationDate: serializer.fromJson<String?>(
        json['commune_nomination_date'],
      ),
      firstTeachingNominationDate: serializer.fromJson<String?>(
        json['first_teaching_nomination_date'],
      ),
      pupilSchoolName: serializer.fromJson<String?>(json['pupil_school_name']),
      pupilSchoolEntryDate: serializer.fromJson<String?>(
        json['pupil_school_entry_date'],
      ),
      pupilSchoolExitDate: serializer.fromJson<String?>(
        json['pupil_school_exit_date'],
      ),
      seniorityGeneralFrom: serializer.fromJson<String?>(
        json['seniority_general_from'],
      ),
      seniorityEmploiFrom: serializer.fromJson<String?>(
        json['seniority_emploi_from'],
      ),
      seniorityRegionFrom: serializer.fromJson<String?>(
        json['seniority_region_from'],
      ),
      seniorityFonctionFrom: serializer.fromJson<String?>(
        json['seniority_fonction_from'],
      ),
      communeCessationDate: serializer.fromJson<String?>(
        json['commune_cessation_date'],
      ),
      newPost: serializer.fromJson<String?>(json['new_post']),
      observations: serializer.fromJson<String?>(json['observations']),
      archivedAt: serializer.fromJson<String?>(json['archived_at']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'last_name': serializer.toJson<String>(lastName),
      'first_names': serializer.toJson<String>(firstNames),
      'sex': serializer.toJson<String?>(sex),
      'matricule': serializer.toJson<String?>(matricule),
      'phone': serializer.toJson<String?>(phone),
      'birth_date': serializer.toJson<String?>(birthDate),
      'birth_place': serializer.toJson<String?>(birthPlace),
      'emploi': serializer.toJson<String?>(emploi),
      'categorie': serializer.toJson<String?>(categorie),
      'echelon': serializer.toJson<String?>(echelon),
      'tenure_status': serializer.toJson<String?>(tenureStatus),
      'status': serializer.toJson<String>(status),
      'commune_nomination_date': serializer.toJson<String?>(
        communeNominationDate,
      ),
      'first_teaching_nomination_date': serializer.toJson<String?>(
        firstTeachingNominationDate,
      ),
      'pupil_school_name': serializer.toJson<String?>(pupilSchoolName),
      'pupil_school_entry_date': serializer.toJson<String?>(
        pupilSchoolEntryDate,
      ),
      'pupil_school_exit_date': serializer.toJson<String?>(pupilSchoolExitDate),
      'seniority_general_from': serializer.toJson<String?>(
        seniorityGeneralFrom,
      ),
      'seniority_emploi_from': serializer.toJson<String?>(seniorityEmploiFrom),
      'seniority_region_from': serializer.toJson<String?>(seniorityRegionFrom),
      'seniority_fonction_from': serializer.toJson<String?>(
        seniorityFonctionFrom,
      ),
      'commune_cessation_date': serializer.toJson<String?>(
        communeCessationDate,
      ),
      'new_post': serializer.toJson<String?>(newPost),
      'observations': serializer.toJson<String?>(observations),
      'archived_at': serializer.toJson<String?>(archivedAt),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  TeacherRow copyWith({
    String? id,
    String? schoolId,
    String? lastName,
    String? firstNames,
    Value<String?> sex = const Value.absent(),
    Value<String?> matricule = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> birthDate = const Value.absent(),
    Value<String?> birthPlace = const Value.absent(),
    Value<String?> emploi = const Value.absent(),
    Value<String?> categorie = const Value.absent(),
    Value<String?> echelon = const Value.absent(),
    Value<String?> tenureStatus = const Value.absent(),
    String? status,
    Value<String?> communeNominationDate = const Value.absent(),
    Value<String?> firstTeachingNominationDate = const Value.absent(),
    Value<String?> pupilSchoolName = const Value.absent(),
    Value<String?> pupilSchoolEntryDate = const Value.absent(),
    Value<String?> pupilSchoolExitDate = const Value.absent(),
    Value<String?> seniorityGeneralFrom = const Value.absent(),
    Value<String?> seniorityEmploiFrom = const Value.absent(),
    Value<String?> seniorityRegionFrom = const Value.absent(),
    Value<String?> seniorityFonctionFrom = const Value.absent(),
    Value<String?> communeCessationDate = const Value.absent(),
    Value<String?> newPost = const Value.absent(),
    Value<String?> observations = const Value.absent(),
    Value<String?> archivedAt = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => TeacherRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    lastName: lastName ?? this.lastName,
    firstNames: firstNames ?? this.firstNames,
    sex: sex.present ? sex.value : this.sex,
    matricule: matricule.present ? matricule.value : this.matricule,
    phone: phone.present ? phone.value : this.phone,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    birthPlace: birthPlace.present ? birthPlace.value : this.birthPlace,
    emploi: emploi.present ? emploi.value : this.emploi,
    categorie: categorie.present ? categorie.value : this.categorie,
    echelon: echelon.present ? echelon.value : this.echelon,
    tenureStatus: tenureStatus.present ? tenureStatus.value : this.tenureStatus,
    status: status ?? this.status,
    communeNominationDate: communeNominationDate.present
        ? communeNominationDate.value
        : this.communeNominationDate,
    firstTeachingNominationDate: firstTeachingNominationDate.present
        ? firstTeachingNominationDate.value
        : this.firstTeachingNominationDate,
    pupilSchoolName: pupilSchoolName.present
        ? pupilSchoolName.value
        : this.pupilSchoolName,
    pupilSchoolEntryDate: pupilSchoolEntryDate.present
        ? pupilSchoolEntryDate.value
        : this.pupilSchoolEntryDate,
    pupilSchoolExitDate: pupilSchoolExitDate.present
        ? pupilSchoolExitDate.value
        : this.pupilSchoolExitDate,
    seniorityGeneralFrom: seniorityGeneralFrom.present
        ? seniorityGeneralFrom.value
        : this.seniorityGeneralFrom,
    seniorityEmploiFrom: seniorityEmploiFrom.present
        ? seniorityEmploiFrom.value
        : this.seniorityEmploiFrom,
    seniorityRegionFrom: seniorityRegionFrom.present
        ? seniorityRegionFrom.value
        : this.seniorityRegionFrom,
    seniorityFonctionFrom: seniorityFonctionFrom.present
        ? seniorityFonctionFrom.value
        : this.seniorityFonctionFrom,
    communeCessationDate: communeCessationDate.present
        ? communeCessationDate.value
        : this.communeCessationDate,
    newPost: newPost.present ? newPost.value : this.newPost,
    observations: observations.present ? observations.value : this.observations,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TeacherRow copyWithCompanion(TeachersCompanion data) {
    return TeacherRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      firstNames: data.firstNames.present
          ? data.firstNames.value
          : this.firstNames,
      sex: data.sex.present ? data.sex.value : this.sex,
      matricule: data.matricule.present ? data.matricule.value : this.matricule,
      phone: data.phone.present ? data.phone.value : this.phone,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      birthPlace: data.birthPlace.present
          ? data.birthPlace.value
          : this.birthPlace,
      emploi: data.emploi.present ? data.emploi.value : this.emploi,
      categorie: data.categorie.present ? data.categorie.value : this.categorie,
      echelon: data.echelon.present ? data.echelon.value : this.echelon,
      tenureStatus: data.tenureStatus.present
          ? data.tenureStatus.value
          : this.tenureStatus,
      status: data.status.present ? data.status.value : this.status,
      communeNominationDate: data.communeNominationDate.present
          ? data.communeNominationDate.value
          : this.communeNominationDate,
      firstTeachingNominationDate: data.firstTeachingNominationDate.present
          ? data.firstTeachingNominationDate.value
          : this.firstTeachingNominationDate,
      pupilSchoolName: data.pupilSchoolName.present
          ? data.pupilSchoolName.value
          : this.pupilSchoolName,
      pupilSchoolEntryDate: data.pupilSchoolEntryDate.present
          ? data.pupilSchoolEntryDate.value
          : this.pupilSchoolEntryDate,
      pupilSchoolExitDate: data.pupilSchoolExitDate.present
          ? data.pupilSchoolExitDate.value
          : this.pupilSchoolExitDate,
      seniorityGeneralFrom: data.seniorityGeneralFrom.present
          ? data.seniorityGeneralFrom.value
          : this.seniorityGeneralFrom,
      seniorityEmploiFrom: data.seniorityEmploiFrom.present
          ? data.seniorityEmploiFrom.value
          : this.seniorityEmploiFrom,
      seniorityRegionFrom: data.seniorityRegionFrom.present
          ? data.seniorityRegionFrom.value
          : this.seniorityRegionFrom,
      seniorityFonctionFrom: data.seniorityFonctionFrom.present
          ? data.seniorityFonctionFrom.value
          : this.seniorityFonctionFrom,
      communeCessationDate: data.communeCessationDate.present
          ? data.communeCessationDate.value
          : this.communeCessationDate,
      newPost: data.newPost.present ? data.newPost.value : this.newPost,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('lastName: $lastName, ')
          ..write('firstNames: $firstNames, ')
          ..write('sex: $sex, ')
          ..write('matricule: $matricule, ')
          ..write('phone: $phone, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('emploi: $emploi, ')
          ..write('categorie: $categorie, ')
          ..write('echelon: $echelon, ')
          ..write('tenureStatus: $tenureStatus, ')
          ..write('status: $status, ')
          ..write('communeNominationDate: $communeNominationDate, ')
          ..write('firstTeachingNominationDate: $firstTeachingNominationDate, ')
          ..write('pupilSchoolName: $pupilSchoolName, ')
          ..write('pupilSchoolEntryDate: $pupilSchoolEntryDate, ')
          ..write('pupilSchoolExitDate: $pupilSchoolExitDate, ')
          ..write('seniorityGeneralFrom: $seniorityGeneralFrom, ')
          ..write('seniorityEmploiFrom: $seniorityEmploiFrom, ')
          ..write('seniorityRegionFrom: $seniorityRegionFrom, ')
          ..write('seniorityFonctionFrom: $seniorityFonctionFrom, ')
          ..write('communeCessationDate: $communeCessationDate, ')
          ..write('newPost: $newPost, ')
          ..write('observations: $observations, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    schoolId,
    lastName,
    firstNames,
    sex,
    matricule,
    phone,
    birthDate,
    birthPlace,
    emploi,
    categorie,
    echelon,
    tenureStatus,
    status,
    communeNominationDate,
    firstTeachingNominationDate,
    pupilSchoolName,
    pupilSchoolEntryDate,
    pupilSchoolExitDate,
    seniorityGeneralFrom,
    seniorityEmploiFrom,
    seniorityRegionFrom,
    seniorityFonctionFrom,
    communeCessationDate,
    newPost,
    observations,
    archivedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.lastName == this.lastName &&
          other.firstNames == this.firstNames &&
          other.sex == this.sex &&
          other.matricule == this.matricule &&
          other.phone == this.phone &&
          other.birthDate == this.birthDate &&
          other.birthPlace == this.birthPlace &&
          other.emploi == this.emploi &&
          other.categorie == this.categorie &&
          other.echelon == this.echelon &&
          other.tenureStatus == this.tenureStatus &&
          other.status == this.status &&
          other.communeNominationDate == this.communeNominationDate &&
          other.firstTeachingNominationDate ==
              this.firstTeachingNominationDate &&
          other.pupilSchoolName == this.pupilSchoolName &&
          other.pupilSchoolEntryDate == this.pupilSchoolEntryDate &&
          other.pupilSchoolExitDate == this.pupilSchoolExitDate &&
          other.seniorityGeneralFrom == this.seniorityGeneralFrom &&
          other.seniorityEmploiFrom == this.seniorityEmploiFrom &&
          other.seniorityRegionFrom == this.seniorityRegionFrom &&
          other.seniorityFonctionFrom == this.seniorityFonctionFrom &&
          other.communeCessationDate == this.communeCessationDate &&
          other.newPost == this.newPost &&
          other.observations == this.observations &&
          other.archivedAt == this.archivedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class TeachersCompanion extends UpdateCompanion<TeacherRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> lastName;
  final Value<String> firstNames;
  final Value<String?> sex;
  final Value<String?> matricule;
  final Value<String?> phone;
  final Value<String?> birthDate;
  final Value<String?> birthPlace;
  final Value<String?> emploi;
  final Value<String?> categorie;
  final Value<String?> echelon;
  final Value<String?> tenureStatus;
  final Value<String> status;
  final Value<String?> communeNominationDate;
  final Value<String?> firstTeachingNominationDate;
  final Value<String?> pupilSchoolName;
  final Value<String?> pupilSchoolEntryDate;
  final Value<String?> pupilSchoolExitDate;
  final Value<String?> seniorityGeneralFrom;
  final Value<String?> seniorityEmploiFrom;
  final Value<String?> seniorityRegionFrom;
  final Value<String?> seniorityFonctionFrom;
  final Value<String?> communeCessationDate;
  final Value<String?> newPost;
  final Value<String?> observations;
  final Value<String?> archivedAt;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const TeachersCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.lastName = const Value.absent(),
    this.firstNames = const Value.absent(),
    this.sex = const Value.absent(),
    this.matricule = const Value.absent(),
    this.phone = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.emploi = const Value.absent(),
    this.categorie = const Value.absent(),
    this.echelon = const Value.absent(),
    this.tenureStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.communeNominationDate = const Value.absent(),
    this.firstTeachingNominationDate = const Value.absent(),
    this.pupilSchoolName = const Value.absent(),
    this.pupilSchoolEntryDate = const Value.absent(),
    this.pupilSchoolExitDate = const Value.absent(),
    this.seniorityGeneralFrom = const Value.absent(),
    this.seniorityEmploiFrom = const Value.absent(),
    this.seniorityRegionFrom = const Value.absent(),
    this.seniorityFonctionFrom = const Value.absent(),
    this.communeCessationDate = const Value.absent(),
    this.newPost = const Value.absent(),
    this.observations = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeachersCompanion.insert({
    required String id,
    required String schoolId,
    required String lastName,
    required String firstNames,
    this.sex = const Value.absent(),
    this.matricule = const Value.absent(),
    this.phone = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.emploi = const Value.absent(),
    this.categorie = const Value.absent(),
    this.echelon = const Value.absent(),
    this.tenureStatus = const Value.absent(),
    this.status = const Value.absent(),
    this.communeNominationDate = const Value.absent(),
    this.firstTeachingNominationDate = const Value.absent(),
    this.pupilSchoolName = const Value.absent(),
    this.pupilSchoolEntryDate = const Value.absent(),
    this.pupilSchoolExitDate = const Value.absent(),
    this.seniorityGeneralFrom = const Value.absent(),
    this.seniorityEmploiFrom = const Value.absent(),
    this.seniorityRegionFrom = const Value.absent(),
    this.seniorityFonctionFrom = const Value.absent(),
    this.communeCessationDate = const Value.absent(),
    this.newPost = const Value.absent(),
    this.observations = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       lastName = Value(lastName),
       firstNames = Value(firstNames),
       updatedAt = Value(updatedAt);
  static Insertable<TeacherRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? lastName,
    Expression<String>? firstNames,
    Expression<String>? sex,
    Expression<String>? matricule,
    Expression<String>? phone,
    Expression<String>? birthDate,
    Expression<String>? birthPlace,
    Expression<String>? emploi,
    Expression<String>? categorie,
    Expression<String>? echelon,
    Expression<String>? tenureStatus,
    Expression<String>? status,
    Expression<String>? communeNominationDate,
    Expression<String>? firstTeachingNominationDate,
    Expression<String>? pupilSchoolName,
    Expression<String>? pupilSchoolEntryDate,
    Expression<String>? pupilSchoolExitDate,
    Expression<String>? seniorityGeneralFrom,
    Expression<String>? seniorityEmploiFrom,
    Expression<String>? seniorityRegionFrom,
    Expression<String>? seniorityFonctionFrom,
    Expression<String>? communeCessationDate,
    Expression<String>? newPost,
    Expression<String>? observations,
    Expression<String>? archivedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (lastName != null) 'last_name': lastName,
      if (firstNames != null) 'first_names': firstNames,
      if (sex != null) 'sex': sex,
      if (matricule != null) 'matricule': matricule,
      if (phone != null) 'phone': phone,
      if (birthDate != null) 'birth_date': birthDate,
      if (birthPlace != null) 'birth_place': birthPlace,
      if (emploi != null) 'emploi': emploi,
      if (categorie != null) 'categorie': categorie,
      if (echelon != null) 'echelon': echelon,
      if (tenureStatus != null) 'tenure_status': tenureStatus,
      if (status != null) 'status': status,
      if (communeNominationDate != null)
        'commune_nomination_date': communeNominationDate,
      if (firstTeachingNominationDate != null)
        'first_teaching_nomination_date': firstTeachingNominationDate,
      if (pupilSchoolName != null) 'pupil_school_name': pupilSchoolName,
      if (pupilSchoolEntryDate != null)
        'pupil_school_entry_date': pupilSchoolEntryDate,
      if (pupilSchoolExitDate != null)
        'pupil_school_exit_date': pupilSchoolExitDate,
      if (seniorityGeneralFrom != null)
        'seniority_general_from': seniorityGeneralFrom,
      if (seniorityEmploiFrom != null)
        'seniority_emploi_from': seniorityEmploiFrom,
      if (seniorityRegionFrom != null)
        'seniority_region_from': seniorityRegionFrom,
      if (seniorityFonctionFrom != null)
        'seniority_fonction_from': seniorityFonctionFrom,
      if (communeCessationDate != null)
        'commune_cessation_date': communeCessationDate,
      if (newPost != null) 'new_post': newPost,
      if (observations != null) 'observations': observations,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeachersCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? lastName,
    Value<String>? firstNames,
    Value<String?>? sex,
    Value<String?>? matricule,
    Value<String?>? phone,
    Value<String?>? birthDate,
    Value<String?>? birthPlace,
    Value<String?>? emploi,
    Value<String?>? categorie,
    Value<String?>? echelon,
    Value<String?>? tenureStatus,
    Value<String>? status,
    Value<String?>? communeNominationDate,
    Value<String?>? firstTeachingNominationDate,
    Value<String?>? pupilSchoolName,
    Value<String?>? pupilSchoolEntryDate,
    Value<String?>? pupilSchoolExitDate,
    Value<String?>? seniorityGeneralFrom,
    Value<String?>? seniorityEmploiFrom,
    Value<String?>? seniorityRegionFrom,
    Value<String?>? seniorityFonctionFrom,
    Value<String?>? communeCessationDate,
    Value<String?>? newPost,
    Value<String?>? observations,
    Value<String?>? archivedAt,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return TeachersCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      lastName: lastName ?? this.lastName,
      firstNames: firstNames ?? this.firstNames,
      sex: sex ?? this.sex,
      matricule: matricule ?? this.matricule,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      emploi: emploi ?? this.emploi,
      categorie: categorie ?? this.categorie,
      echelon: echelon ?? this.echelon,
      tenureStatus: tenureStatus ?? this.tenureStatus,
      status: status ?? this.status,
      communeNominationDate:
          communeNominationDate ?? this.communeNominationDate,
      firstTeachingNominationDate:
          firstTeachingNominationDate ?? this.firstTeachingNominationDate,
      pupilSchoolName: pupilSchoolName ?? this.pupilSchoolName,
      pupilSchoolEntryDate: pupilSchoolEntryDate ?? this.pupilSchoolEntryDate,
      pupilSchoolExitDate: pupilSchoolExitDate ?? this.pupilSchoolExitDate,
      seniorityGeneralFrom: seniorityGeneralFrom ?? this.seniorityGeneralFrom,
      seniorityEmploiFrom: seniorityEmploiFrom ?? this.seniorityEmploiFrom,
      seniorityRegionFrom: seniorityRegionFrom ?? this.seniorityRegionFrom,
      seniorityFonctionFrom:
          seniorityFonctionFrom ?? this.seniorityFonctionFrom,
      communeCessationDate: communeCessationDate ?? this.communeCessationDate,
      newPost: newPost ?? this.newPost,
      observations: observations ?? this.observations,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (firstNames.present) {
      map['first_names'] = Variable<String>(firstNames.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (matricule.present) {
      map['matricule'] = Variable<String>(matricule.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (birthPlace.present) {
      map['birth_place'] = Variable<String>(birthPlace.value);
    }
    if (emploi.present) {
      map['emploi'] = Variable<String>(emploi.value);
    }
    if (categorie.present) {
      map['categorie'] = Variable<String>(categorie.value);
    }
    if (echelon.present) {
      map['echelon'] = Variable<String>(echelon.value);
    }
    if (tenureStatus.present) {
      map['tenure_status'] = Variable<String>(tenureStatus.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (communeNominationDate.present) {
      map['commune_nomination_date'] = Variable<String>(
        communeNominationDate.value,
      );
    }
    if (firstTeachingNominationDate.present) {
      map['first_teaching_nomination_date'] = Variable<String>(
        firstTeachingNominationDate.value,
      );
    }
    if (pupilSchoolName.present) {
      map['pupil_school_name'] = Variable<String>(pupilSchoolName.value);
    }
    if (pupilSchoolEntryDate.present) {
      map['pupil_school_entry_date'] = Variable<String>(
        pupilSchoolEntryDate.value,
      );
    }
    if (pupilSchoolExitDate.present) {
      map['pupil_school_exit_date'] = Variable<String>(
        pupilSchoolExitDate.value,
      );
    }
    if (seniorityGeneralFrom.present) {
      map['seniority_general_from'] = Variable<String>(
        seniorityGeneralFrom.value,
      );
    }
    if (seniorityEmploiFrom.present) {
      map['seniority_emploi_from'] = Variable<String>(
        seniorityEmploiFrom.value,
      );
    }
    if (seniorityRegionFrom.present) {
      map['seniority_region_from'] = Variable<String>(
        seniorityRegionFrom.value,
      );
    }
    if (seniorityFonctionFrom.present) {
      map['seniority_fonction_from'] = Variable<String>(
        seniorityFonctionFrom.value,
      );
    }
    if (communeCessationDate.present) {
      map['commune_cessation_date'] = Variable<String>(
        communeCessationDate.value,
      );
    }
    if (newPost.present) {
      map['new_post'] = Variable<String>(newPost.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeachersCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('lastName: $lastName, ')
          ..write('firstNames: $firstNames, ')
          ..write('sex: $sex, ')
          ..write('matricule: $matricule, ')
          ..write('phone: $phone, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('emploi: $emploi, ')
          ..write('categorie: $categorie, ')
          ..write('echelon: $echelon, ')
          ..write('tenureStatus: $tenureStatus, ')
          ..write('status: $status, ')
          ..write('communeNominationDate: $communeNominationDate, ')
          ..write('firstTeachingNominationDate: $firstTeachingNominationDate, ')
          ..write('pupilSchoolName: $pupilSchoolName, ')
          ..write('pupilSchoolEntryDate: $pupilSchoolEntryDate, ')
          ..write('pupilSchoolExitDate: $pupilSchoolExitDate, ')
          ..write('seniorityGeneralFrom: $seniorityGeneralFrom, ')
          ..write('seniorityEmploiFrom: $seniorityEmploiFrom, ')
          ..write('seniorityRegionFrom: $seniorityRegionFrom, ')
          ..write('seniorityFonctionFrom: $seniorityFonctionFrom, ')
          ..write('communeCessationDate: $communeCessationDate, ')
          ..write('newPost: $newPost, ')
          ..write('observations: $observations, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TeacherPostings extends Table
    with TableInfo<TeacherPostings, TeacherPostingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TeacherPostings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _communeMeta = const VerificationMeta(
    'commune',
  );
  late final GeneratedColumn<String> commune = GeneratedColumn<String>(
    'commune',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nominatedOnMeta = const VerificationMeta(
    'nominatedOn',
  );
  late final GeneratedColumn<String> nominatedOn = GeneratedColumn<String>(
    'nominated_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    teacherId,
    commune,
    nominatedOn,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teacher_postings';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeacherPostingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('commune')) {
      context.handle(
        _communeMeta,
        commune.isAcceptableOrUnknown(data['commune']!, _communeMeta),
      );
    } else if (isInserting) {
      context.missing(_communeMeta);
    }
    if (data.containsKey('nominated_on')) {
      context.handle(
        _nominatedOnMeta,
        nominatedOn.isAcceptableOrUnknown(
          data['nominated_on']!,
          _nominatedOnMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeacherPostingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherPostingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      )!,
      commune: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commune'],
      )!,
      nominatedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nominated_on'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  TeacherPostings createAlias(String alias) {
    return TeacherPostings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TeacherPostingRow extends DataClass
    implements Insertable<TeacherPostingRow> {
  final String id;
  final String schoolId;
  final String teacherId;
  final String commune;
  final String? nominatedOn;
  final int sortOrder;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const TeacherPostingRow({
    required this.id,
    required this.schoolId,
    required this.teacherId,
    required this.commune,
    this.nominatedOn,
    required this.sortOrder,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['teacher_id'] = Variable<String>(teacherId);
    map['commune'] = Variable<String>(commune);
    if (!nullToAbsent || nominatedOn != null) {
      map['nominated_on'] = Variable<String>(nominatedOn);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  TeacherPostingsCompanion toCompanion(bool nullToAbsent) {
    return TeacherPostingsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      teacherId: Value(teacherId),
      commune: Value(commune),
      nominatedOn: nominatedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(nominatedOn),
      sortOrder: Value(sortOrder),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory TeacherPostingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherPostingRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      teacherId: serializer.fromJson<String>(json['teacher_id']),
      commune: serializer.fromJson<String>(json['commune']),
      nominatedOn: serializer.fromJson<String?>(json['nominated_on']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'teacher_id': serializer.toJson<String>(teacherId),
      'commune': serializer.toJson<String>(commune),
      'nominated_on': serializer.toJson<String?>(nominatedOn),
      'sort_order': serializer.toJson<int>(sortOrder),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  TeacherPostingRow copyWith({
    String? id,
    String? schoolId,
    String? teacherId,
    String? commune,
    Value<String?> nominatedOn = const Value.absent(),
    int? sortOrder,
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => TeacherPostingRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    teacherId: teacherId ?? this.teacherId,
    commune: commune ?? this.commune,
    nominatedOn: nominatedOn.present ? nominatedOn.value : this.nominatedOn,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TeacherPostingRow copyWithCompanion(TeacherPostingsCompanion data) {
    return TeacherPostingRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      commune: data.commune.present ? data.commune.value : this.commune,
      nominatedOn: data.nominatedOn.present
          ? data.nominatedOn.value
          : this.nominatedOn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherPostingRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('commune: $commune, ')
          ..write('nominatedOn: $nominatedOn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    teacherId,
    commune,
    nominatedOn,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherPostingRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.teacherId == this.teacherId &&
          other.commune == this.commune &&
          other.nominatedOn == this.nominatedOn &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class TeacherPostingsCompanion extends UpdateCompanion<TeacherPostingRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> teacherId;
  final Value<String> commune;
  final Value<String?> nominatedOn;
  final Value<int> sortOrder;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const TeacherPostingsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.commune = const Value.absent(),
    this.nominatedOn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeacherPostingsCompanion.insert({
    required String id,
    required String schoolId,
    required String teacherId,
    required String commune,
    this.nominatedOn = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       teacherId = Value(teacherId),
       commune = Value(commune),
       updatedAt = Value(updatedAt);
  static Insertable<TeacherPostingRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? teacherId,
    Expression<String>? commune,
    Expression<String>? nominatedOn,
    Expression<int>? sortOrder,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (commune != null) 'commune': commune,
      if (nominatedOn != null) 'nominated_on': nominatedOn,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeacherPostingsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? teacherId,
    Value<String>? commune,
    Value<String?>? nominatedOn,
    Value<int>? sortOrder,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return TeacherPostingsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      teacherId: teacherId ?? this.teacherId,
      commune: commune ?? this.commune,
      nominatedOn: nominatedOn ?? this.nominatedOn,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (commune.present) {
      map['commune'] = Variable<String>(commune.value);
    }
    if (nominatedOn.present) {
      map['nominated_on'] = Variable<String>(nominatedOn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeacherPostingsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('commune: $commune, ')
          ..write('nominatedOn: $nominatedOn, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TeacherInterruptions extends Table
    with TableInfo<TeacherInterruptions, TeacherInterruptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TeacherInterruptions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _causeMeta = const VerificationMeta('cause');
  late final GeneratedColumn<String> cause = GeneratedColumn<String>(
    'cause',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  late final GeneratedColumn<String> startsOn = GeneratedColumn<String>(
    'starts_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  late final GeneratedColumn<String> endsOn = GeneratedColumn<String>(
    'ends_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _durationTextMeta = const VerificationMeta(
    'durationText',
  );
  late final GeneratedColumn<String> durationText = GeneratedColumn<String>(
    'duration_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    teacherId,
    cause,
    startsOn,
    endsOn,
    durationText,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teacher_interruptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeacherInterruptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('cause')) {
      context.handle(
        _causeMeta,
        cause.isAcceptableOrUnknown(data['cause']!, _causeMeta),
      );
    } else if (isInserting) {
      context.missing(_causeMeta);
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    }
    if (data.containsKey('duration_text')) {
      context.handle(
        _durationTextMeta,
        durationText.isAcceptableOrUnknown(
          data['duration_text']!,
          _durationTextMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeacherInterruptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherInterruptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      )!,
      cause: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cause'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}starts_on'],
      ),
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ends_on'],
      ),
      durationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}duration_text'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  TeacherInterruptions createAlias(String alias) {
    return TeacherInterruptions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TeacherInterruptionRow extends DataClass
    implements Insertable<TeacherInterruptionRow> {
  final String id;
  final String schoolId;
  final String teacherId;
  final String cause;
  final String? startsOn;
  final String? endsOn;
  final String? durationText;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const TeacherInterruptionRow({
    required this.id,
    required this.schoolId,
    required this.teacherId,
    required this.cause,
    this.startsOn,
    this.endsOn,
    this.durationText,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['teacher_id'] = Variable<String>(teacherId);
    map['cause'] = Variable<String>(cause);
    if (!nullToAbsent || startsOn != null) {
      map['starts_on'] = Variable<String>(startsOn);
    }
    if (!nullToAbsent || endsOn != null) {
      map['ends_on'] = Variable<String>(endsOn);
    }
    if (!nullToAbsent || durationText != null) {
      map['duration_text'] = Variable<String>(durationText);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  TeacherInterruptionsCompanion toCompanion(bool nullToAbsent) {
    return TeacherInterruptionsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      teacherId: Value(teacherId),
      cause: Value(cause),
      startsOn: startsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(startsOn),
      endsOn: endsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endsOn),
      durationText: durationText == null && nullToAbsent
          ? const Value.absent()
          : Value(durationText),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory TeacherInterruptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherInterruptionRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      teacherId: serializer.fromJson<String>(json['teacher_id']),
      cause: serializer.fromJson<String>(json['cause']),
      startsOn: serializer.fromJson<String?>(json['starts_on']),
      endsOn: serializer.fromJson<String?>(json['ends_on']),
      durationText: serializer.fromJson<String?>(json['duration_text']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'teacher_id': serializer.toJson<String>(teacherId),
      'cause': serializer.toJson<String>(cause),
      'starts_on': serializer.toJson<String?>(startsOn),
      'ends_on': serializer.toJson<String?>(endsOn),
      'duration_text': serializer.toJson<String?>(durationText),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  TeacherInterruptionRow copyWith({
    String? id,
    String? schoolId,
    String? teacherId,
    String? cause,
    Value<String?> startsOn = const Value.absent(),
    Value<String?> endsOn = const Value.absent(),
    Value<String?> durationText = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => TeacherInterruptionRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    teacherId: teacherId ?? this.teacherId,
    cause: cause ?? this.cause,
    startsOn: startsOn.present ? startsOn.value : this.startsOn,
    endsOn: endsOn.present ? endsOn.value : this.endsOn,
    durationText: durationText.present ? durationText.value : this.durationText,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TeacherInterruptionRow copyWithCompanion(TeacherInterruptionsCompanion data) {
    return TeacherInterruptionRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      cause: data.cause.present ? data.cause.value : this.cause,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      durationText: data.durationText.present
          ? data.durationText.value
          : this.durationText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherInterruptionRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('cause: $cause, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('durationText: $durationText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    teacherId,
    cause,
    startsOn,
    endsOn,
    durationText,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherInterruptionRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.teacherId == this.teacherId &&
          other.cause == this.cause &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.durationText == this.durationText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class TeacherInterruptionsCompanion
    extends UpdateCompanion<TeacherInterruptionRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> teacherId;
  final Value<String> cause;
  final Value<String?> startsOn;
  final Value<String?> endsOn;
  final Value<String?> durationText;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const TeacherInterruptionsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.cause = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.durationText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeacherInterruptionsCompanion.insert({
    required String id,
    required String schoolId,
    required String teacherId,
    required String cause,
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.durationText = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       teacherId = Value(teacherId),
       cause = Value(cause),
       updatedAt = Value(updatedAt);
  static Insertable<TeacherInterruptionRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? teacherId,
    Expression<String>? cause,
    Expression<String>? startsOn,
    Expression<String>? endsOn,
    Expression<String>? durationText,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (cause != null) 'cause': cause,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (durationText != null) 'duration_text': durationText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeacherInterruptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? teacherId,
    Value<String>? cause,
    Value<String?>? startsOn,
    Value<String?>? endsOn,
    Value<String?>? durationText,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return TeacherInterruptionsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      teacherId: teacherId ?? this.teacherId,
      cause: cause ?? this.cause,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      durationText: durationText ?? this.durationText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (cause.present) {
      map['cause'] = Variable<String>(cause.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<String>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<String>(endsOn.value);
    }
    if (durationText.present) {
      map['duration_text'] = Variable<String>(durationText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeacherInterruptionsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('cause: $cause, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('durationText: $durationText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TeacherAwards extends Table
    with TableInfo<TeacherAwards, TeacherAwardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TeacherAwards(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _awardedOnMeta = const VerificationMeta(
    'awardedOn',
  );
  late final GeneratedColumn<String> awardedOn = GeneratedColumn<String>(
    'awarded_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    teacherId,
    label,
    awardedOn,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teacher_awards';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeacherAwardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('awarded_on')) {
      context.handle(
        _awardedOnMeta,
        awardedOn.isAcceptableOrUnknown(data['awarded_on']!, _awardedOnMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeacherAwardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherAwardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      awardedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}awarded_on'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  TeacherAwards createAlias(String alias) {
    return TeacherAwards(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TeacherAwardRow extends DataClass implements Insertable<TeacherAwardRow> {
  final String id;
  final String schoolId;
  final String teacherId;
  final String label;
  final String? awardedOn;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const TeacherAwardRow({
    required this.id,
    required this.schoolId,
    required this.teacherId,
    required this.label,
    this.awardedOn,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['teacher_id'] = Variable<String>(teacherId);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || awardedOn != null) {
      map['awarded_on'] = Variable<String>(awardedOn);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  TeacherAwardsCompanion toCompanion(bool nullToAbsent) {
    return TeacherAwardsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      teacherId: Value(teacherId),
      label: Value(label),
      awardedOn: awardedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(awardedOn),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory TeacherAwardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherAwardRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      teacherId: serializer.fromJson<String>(json['teacher_id']),
      label: serializer.fromJson<String>(json['label']),
      awardedOn: serializer.fromJson<String?>(json['awarded_on']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'teacher_id': serializer.toJson<String>(teacherId),
      'label': serializer.toJson<String>(label),
      'awarded_on': serializer.toJson<String?>(awardedOn),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  TeacherAwardRow copyWith({
    String? id,
    String? schoolId,
    String? teacherId,
    String? label,
    Value<String?> awardedOn = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => TeacherAwardRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    teacherId: teacherId ?? this.teacherId,
    label: label ?? this.label,
    awardedOn: awardedOn.present ? awardedOn.value : this.awardedOn,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TeacherAwardRow copyWithCompanion(TeacherAwardsCompanion data) {
    return TeacherAwardRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      label: data.label.present ? data.label.value : this.label,
      awardedOn: data.awardedOn.present ? data.awardedOn.value : this.awardedOn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherAwardRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('label: $label, ')
          ..write('awardedOn: $awardedOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    teacherId,
    label,
    awardedOn,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherAwardRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.teacherId == this.teacherId &&
          other.label == this.label &&
          other.awardedOn == this.awardedOn &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class TeacherAwardsCompanion extends UpdateCompanion<TeacherAwardRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> teacherId;
  final Value<String> label;
  final Value<String?> awardedOn;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const TeacherAwardsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.label = const Value.absent(),
    this.awardedOn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeacherAwardsCompanion.insert({
    required String id,
    required String schoolId,
    required String teacherId,
    required String label,
    this.awardedOn = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       teacherId = Value(teacherId),
       label = Value(label),
       updatedAt = Value(updatedAt);
  static Insertable<TeacherAwardRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? teacherId,
    Expression<String>? label,
    Expression<String>? awardedOn,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (label != null) 'label': label,
      if (awardedOn != null) 'awarded_on': awardedOn,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeacherAwardsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? teacherId,
    Value<String>? label,
    Value<String?>? awardedOn,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return TeacherAwardsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      teacherId: teacherId ?? this.teacherId,
      label: label ?? this.label,
      awardedOn: awardedOn ?? this.awardedOn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (awardedOn.present) {
      map['awarded_on'] = Variable<String>(awardedOn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeacherAwardsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('label: $label, ')
          ..write('awardedOn: $awardedOn, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TeacherDiplomas extends Table
    with TableInfo<TeacherDiplomas, TeacherDiplomaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TeacherDiplomas(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _natureMeta = const VerificationMeta('nature');
  late final GeneratedColumn<String> nature = GeneratedColumn<String>(
    'nature',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deliveredOnMeta = const VerificationMeta(
    'deliveredOn',
  );
  late final GeneratedColumn<String> deliveredOn = GeneratedColumn<String>(
    'delivered_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isAcademicMeta = const VerificationMeta(
    'isAcademic',
  );
  late final GeneratedColumn<bool> isAcademic = GeneratedColumn<bool>(
    'is_academic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    teacherId,
    nature,
    deliveredOn,
    isAcademic,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teacher_diplomas';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeacherDiplomaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('nature')) {
      context.handle(
        _natureMeta,
        nature.isAcceptableOrUnknown(data['nature']!, _natureMeta),
      );
    } else if (isInserting) {
      context.missing(_natureMeta);
    }
    if (data.containsKey('delivered_on')) {
      context.handle(
        _deliveredOnMeta,
        deliveredOn.isAcceptableOrUnknown(
          data['delivered_on']!,
          _deliveredOnMeta,
        ),
      );
    }
    if (data.containsKey('is_academic')) {
      context.handle(
        _isAcademicMeta,
        isAcademic.isAcceptableOrUnknown(data['is_academic']!, _isAcademicMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeacherDiplomaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherDiplomaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      )!,
      nature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nature'],
      )!,
      deliveredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivered_on'],
      ),
      isAcademic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_academic'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  TeacherDiplomas createAlias(String alias) {
    return TeacherDiplomas(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TeacherDiplomaRow extends DataClass
    implements Insertable<TeacherDiplomaRow> {
  final String id;
  final String schoolId;
  final String teacherId;
  final String nature;
  final String? deliveredOn;
  final bool isAcademic;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const TeacherDiplomaRow({
    required this.id,
    required this.schoolId,
    required this.teacherId,
    required this.nature,
    this.deliveredOn,
    required this.isAcademic,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['teacher_id'] = Variable<String>(teacherId);
    map['nature'] = Variable<String>(nature);
    if (!nullToAbsent || deliveredOn != null) {
      map['delivered_on'] = Variable<String>(deliveredOn);
    }
    map['is_academic'] = Variable<bool>(isAcademic);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  TeacherDiplomasCompanion toCompanion(bool nullToAbsent) {
    return TeacherDiplomasCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      teacherId: Value(teacherId),
      nature: Value(nature),
      deliveredOn: deliveredOn == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredOn),
      isAcademic: Value(isAcademic),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory TeacherDiplomaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherDiplomaRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      teacherId: serializer.fromJson<String>(json['teacher_id']),
      nature: serializer.fromJson<String>(json['nature']),
      deliveredOn: serializer.fromJson<String?>(json['delivered_on']),
      isAcademic: serializer.fromJson<bool>(json['is_academic']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'teacher_id': serializer.toJson<String>(teacherId),
      'nature': serializer.toJson<String>(nature),
      'delivered_on': serializer.toJson<String?>(deliveredOn),
      'is_academic': serializer.toJson<bool>(isAcademic),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  TeacherDiplomaRow copyWith({
    String? id,
    String? schoolId,
    String? teacherId,
    String? nature,
    Value<String?> deliveredOn = const Value.absent(),
    bool? isAcademic,
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => TeacherDiplomaRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    teacherId: teacherId ?? this.teacherId,
    nature: nature ?? this.nature,
    deliveredOn: deliveredOn.present ? deliveredOn.value : this.deliveredOn,
    isAcademic: isAcademic ?? this.isAcademic,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TeacherDiplomaRow copyWithCompanion(TeacherDiplomasCompanion data) {
    return TeacherDiplomaRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      nature: data.nature.present ? data.nature.value : this.nature,
      deliveredOn: data.deliveredOn.present
          ? data.deliveredOn.value
          : this.deliveredOn,
      isAcademic: data.isAcademic.present
          ? data.isAcademic.value
          : this.isAcademic,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherDiplomaRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('nature: $nature, ')
          ..write('deliveredOn: $deliveredOn, ')
          ..write('isAcademic: $isAcademic, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    teacherId,
    nature,
    deliveredOn,
    isAcademic,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherDiplomaRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.teacherId == this.teacherId &&
          other.nature == this.nature &&
          other.deliveredOn == this.deliveredOn &&
          other.isAcademic == this.isAcademic &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class TeacherDiplomasCompanion extends UpdateCompanion<TeacherDiplomaRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> teacherId;
  final Value<String> nature;
  final Value<String?> deliveredOn;
  final Value<bool> isAcademic;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const TeacherDiplomasCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.nature = const Value.absent(),
    this.deliveredOn = const Value.absent(),
    this.isAcademic = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeacherDiplomasCompanion.insert({
    required String id,
    required String schoolId,
    required String teacherId,
    required String nature,
    this.deliveredOn = const Value.absent(),
    this.isAcademic = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       teacherId = Value(teacherId),
       nature = Value(nature),
       updatedAt = Value(updatedAt);
  static Insertable<TeacherDiplomaRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? teacherId,
    Expression<String>? nature,
    Expression<String>? deliveredOn,
    Expression<bool>? isAcademic,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (nature != null) 'nature': nature,
      if (deliveredOn != null) 'delivered_on': deliveredOn,
      if (isAcademic != null) 'is_academic': isAcademic,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeacherDiplomasCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? teacherId,
    Value<String>? nature,
    Value<String?>? deliveredOn,
    Value<bool>? isAcademic,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return TeacherDiplomasCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      teacherId: teacherId ?? this.teacherId,
      nature: nature ?? this.nature,
      deliveredOn: deliveredOn ?? this.deliveredOn,
      isAcademic: isAcademic ?? this.isAcademic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (nature.present) {
      map['nature'] = Variable<String>(nature.value);
    }
    if (deliveredOn.present) {
      map['delivered_on'] = Variable<String>(deliveredOn.value);
    }
    if (isAcademic.present) {
      map['is_academic'] = Variable<bool>(isAcademic.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeacherDiplomasCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('nature: $nature, ')
          ..write('deliveredOn: $deliveredOn, ')
          ..write('isAcademic: $isAcademic, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Classes extends Table with TableInfo<Classes, ClassRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Classes(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _schoolYearIdMeta = const VerificationMeta(
    'schoolYearId',
  );
  late final GeneratedColumn<String> schoolYearId = GeneratedColumn<String>(
    'school_year_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _levelCodeMeta = const VerificationMeta(
    'levelCode',
  );
  late final GeneratedColumn<String> levelCode = GeneratedColumn<String>(
    'level_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _mainTeacherIdMeta = const VerificationMeta(
    'mainTeacherId',
  );
  late final GeneratedColumn<String> mainTeacherId = GeneratedColumn<String>(
    'main_teacher_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    schoolYearId,
    levelCode,
    name,
    mainTeacherId,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('school_year_id')) {
      context.handle(
        _schoolYearIdMeta,
        schoolYearId.isAcceptableOrUnknown(
          data['school_year_id']!,
          _schoolYearIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schoolYearIdMeta);
    }
    if (data.containsKey('level_code')) {
      context.handle(
        _levelCodeMeta,
        levelCode.isAcceptableOrUnknown(data['level_code']!, _levelCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_levelCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('main_teacher_id')) {
      context.handle(
        _mainTeacherIdMeta,
        mainTeacherId.isAcceptableOrUnknown(
          data['main_teacher_id']!,
          _mainTeacherIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      schoolYearId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_year_id'],
      )!,
      levelCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mainTeacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}main_teacher_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Classes createAlias(String alias) {
    return Classes(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ClassRow extends DataClass implements Insertable<ClassRow> {
  final String id;
  final String schoolId;
  final String schoolYearId;
  final String levelCode;
  final String name;
  final String? mainTeacherId;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const ClassRow({
    required this.id,
    required this.schoolId,
    required this.schoolYearId,
    required this.levelCode,
    required this.name,
    this.mainTeacherId,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['school_year_id'] = Variable<String>(schoolYearId);
    map['level_code'] = Variable<String>(levelCode);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || mainTeacherId != null) {
      map['main_teacher_id'] = Variable<String>(mainTeacherId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  ClassesCompanion toCompanion(bool nullToAbsent) {
    return ClassesCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      schoolYearId: Value(schoolYearId),
      levelCode: Value(levelCode),
      name: Value(name),
      mainTeacherId: mainTeacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(mainTeacherId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory ClassRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      schoolYearId: serializer.fromJson<String>(json['school_year_id']),
      levelCode: serializer.fromJson<String>(json['level_code']),
      name: serializer.fromJson<String>(json['name']),
      mainTeacherId: serializer.fromJson<String?>(json['main_teacher_id']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'school_year_id': serializer.toJson<String>(schoolYearId),
      'level_code': serializer.toJson<String>(levelCode),
      'name': serializer.toJson<String>(name),
      'main_teacher_id': serializer.toJson<String?>(mainTeacherId),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  ClassRow copyWith({
    String? id,
    String? schoolId,
    String? schoolYearId,
    String? levelCode,
    String? name,
    Value<String?> mainTeacherId = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => ClassRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    schoolYearId: schoolYearId ?? this.schoolYearId,
    levelCode: levelCode ?? this.levelCode,
    name: name ?? this.name,
    mainTeacherId: mainTeacherId.present
        ? mainTeacherId.value
        : this.mainTeacherId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  ClassRow copyWithCompanion(ClassesCompanion data) {
    return ClassRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      schoolYearId: data.schoolYearId.present
          ? data.schoolYearId.value
          : this.schoolYearId,
      levelCode: data.levelCode.present ? data.levelCode.value : this.levelCode,
      name: data.name.present ? data.name.value : this.name,
      mainTeacherId: data.mainTeacherId.present
          ? data.mainTeacherId.value
          : this.mainTeacherId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('schoolYearId: $schoolYearId, ')
          ..write('levelCode: $levelCode, ')
          ..write('name: $name, ')
          ..write('mainTeacherId: $mainTeacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    schoolYearId,
    levelCode,
    name,
    mainTeacherId,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.schoolYearId == this.schoolYearId &&
          other.levelCode == this.levelCode &&
          other.name == this.name &&
          other.mainTeacherId == this.mainTeacherId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class ClassesCompanion extends UpdateCompanion<ClassRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> schoolYearId;
  final Value<String> levelCode;
  final Value<String> name;
  final Value<String?> mainTeacherId;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const ClassesCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.schoolYearId = const Value.absent(),
    this.levelCode = const Value.absent(),
    this.name = const Value.absent(),
    this.mainTeacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassesCompanion.insert({
    required String id,
    required String schoolId,
    required String schoolYearId,
    required String levelCode,
    required String name,
    this.mainTeacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       schoolYearId = Value(schoolYearId),
       levelCode = Value(levelCode),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<ClassRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? schoolYearId,
    Expression<String>? levelCode,
    Expression<String>? name,
    Expression<String>? mainTeacherId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (schoolYearId != null) 'school_year_id': schoolYearId,
      if (levelCode != null) 'level_code': levelCode,
      if (name != null) 'name': name,
      if (mainTeacherId != null) 'main_teacher_id': mainTeacherId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassesCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? schoolYearId,
    Value<String>? levelCode,
    Value<String>? name,
    Value<String?>? mainTeacherId,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return ClassesCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      schoolYearId: schoolYearId ?? this.schoolYearId,
      levelCode: levelCode ?? this.levelCode,
      name: name ?? this.name,
      mainTeacherId: mainTeacherId ?? this.mainTeacherId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (schoolYearId.present) {
      map['school_year_id'] = Variable<String>(schoolYearId.value);
    }
    if (levelCode.present) {
      map['level_code'] = Variable<String>(levelCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mainTeacherId.present) {
      map['main_teacher_id'] = Variable<String>(mainTeacherId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassesCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('schoolYearId: $schoolYearId, ')
          ..write('levelCode: $levelCode, ')
          ..write('name: $name, ')
          ..write('mainTeacherId: $mainTeacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TeacherYearAssignments extends Table
    with TableInfo<TeacherYearAssignments, TeacherAssignmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TeacherYearAssignments(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _schoolYearIdMeta = const VerificationMeta(
    'schoolYearId',
  );
  late final GeneratedColumn<String> schoolYearId = GeneratedColumn<String>(
    'school_year_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _serviceLabelMeta = const VerificationMeta(
    'serviceLabel',
  );
  late final GeneratedColumn<String> serviceLabel = GeneratedColumn<String>(
    'service_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _fonctionMeta = const VerificationMeta(
    'fonction',
  );
  late final GeneratedColumn<String> fonction = GeneratedColumn<String>(
    'fonction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    schoolYearId,
    teacherId,
    classId,
    serviceLabel,
    fonction,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teacher_year_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeacherAssignmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('school_year_id')) {
      context.handle(
        _schoolYearIdMeta,
        schoolYearId.isAcceptableOrUnknown(
          data['school_year_id']!,
          _schoolYearIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schoolYearIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    }
    if (data.containsKey('service_label')) {
      context.handle(
        _serviceLabelMeta,
        serviceLabel.isAcceptableOrUnknown(
          data['service_label']!,
          _serviceLabelMeta,
        ),
      );
    }
    if (data.containsKey('fonction')) {
      context.handle(
        _fonctionMeta,
        fonction.isAcceptableOrUnknown(data['fonction']!, _fonctionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeacherAssignmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherAssignmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      schoolYearId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_year_id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      ),
      serviceLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_label'],
      ),
      fonction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fonction'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  TeacherYearAssignments createAlias(String alias) {
    return TeacherYearAssignments(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TeacherAssignmentRow extends DataClass
    implements Insertable<TeacherAssignmentRow> {
  final String id;
  final String schoolId;
  final String schoolYearId;
  final String teacherId;
  final String? classId;
  final String? serviceLabel;
  final String? fonction;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const TeacherAssignmentRow({
    required this.id,
    required this.schoolId,
    required this.schoolYearId,
    required this.teacherId,
    this.classId,
    this.serviceLabel,
    this.fonction,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['school_year_id'] = Variable<String>(schoolYearId);
    map['teacher_id'] = Variable<String>(teacherId);
    if (!nullToAbsent || classId != null) {
      map['class_id'] = Variable<String>(classId);
    }
    if (!nullToAbsent || serviceLabel != null) {
      map['service_label'] = Variable<String>(serviceLabel);
    }
    if (!nullToAbsent || fonction != null) {
      map['fonction'] = Variable<String>(fonction);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  TeacherYearAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return TeacherYearAssignmentsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      schoolYearId: Value(schoolYearId),
      teacherId: Value(teacherId),
      classId: classId == null && nullToAbsent
          ? const Value.absent()
          : Value(classId),
      serviceLabel: serviceLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceLabel),
      fonction: fonction == null && nullToAbsent
          ? const Value.absent()
          : Value(fonction),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory TeacherAssignmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherAssignmentRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      schoolYearId: serializer.fromJson<String>(json['school_year_id']),
      teacherId: serializer.fromJson<String>(json['teacher_id']),
      classId: serializer.fromJson<String?>(json['class_id']),
      serviceLabel: serializer.fromJson<String?>(json['service_label']),
      fonction: serializer.fromJson<String?>(json['fonction']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'school_year_id': serializer.toJson<String>(schoolYearId),
      'teacher_id': serializer.toJson<String>(teacherId),
      'class_id': serializer.toJson<String?>(classId),
      'service_label': serializer.toJson<String?>(serviceLabel),
      'fonction': serializer.toJson<String?>(fonction),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  TeacherAssignmentRow copyWith({
    String? id,
    String? schoolId,
    String? schoolYearId,
    String? teacherId,
    Value<String?> classId = const Value.absent(),
    Value<String?> serviceLabel = const Value.absent(),
    Value<String?> fonction = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => TeacherAssignmentRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    schoolYearId: schoolYearId ?? this.schoolYearId,
    teacherId: teacherId ?? this.teacherId,
    classId: classId.present ? classId.value : this.classId,
    serviceLabel: serviceLabel.present ? serviceLabel.value : this.serviceLabel,
    fonction: fonction.present ? fonction.value : this.fonction,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TeacherAssignmentRow copyWithCompanion(TeacherYearAssignmentsCompanion data) {
    return TeacherAssignmentRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      schoolYearId: data.schoolYearId.present
          ? data.schoolYearId.value
          : this.schoolYearId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      classId: data.classId.present ? data.classId.value : this.classId,
      serviceLabel: data.serviceLabel.present
          ? data.serviceLabel.value
          : this.serviceLabel,
      fonction: data.fonction.present ? data.fonction.value : this.fonction,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherAssignmentRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('schoolYearId: $schoolYearId, ')
          ..write('teacherId: $teacherId, ')
          ..write('classId: $classId, ')
          ..write('serviceLabel: $serviceLabel, ')
          ..write('fonction: $fonction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    schoolYearId,
    teacherId,
    classId,
    serviceLabel,
    fonction,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherAssignmentRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.schoolYearId == this.schoolYearId &&
          other.teacherId == this.teacherId &&
          other.classId == this.classId &&
          other.serviceLabel == this.serviceLabel &&
          other.fonction == this.fonction &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class TeacherYearAssignmentsCompanion
    extends UpdateCompanion<TeacherAssignmentRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> schoolYearId;
  final Value<String> teacherId;
  final Value<String?> classId;
  final Value<String?> serviceLabel;
  final Value<String?> fonction;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const TeacherYearAssignmentsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.schoolYearId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.classId = const Value.absent(),
    this.serviceLabel = const Value.absent(),
    this.fonction = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeacherYearAssignmentsCompanion.insert({
    required String id,
    required String schoolId,
    required String schoolYearId,
    required String teacherId,
    this.classId = const Value.absent(),
    this.serviceLabel = const Value.absent(),
    this.fonction = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       schoolYearId = Value(schoolYearId),
       teacherId = Value(teacherId),
       updatedAt = Value(updatedAt);
  static Insertable<TeacherAssignmentRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? schoolYearId,
    Expression<String>? teacherId,
    Expression<String>? classId,
    Expression<String>? serviceLabel,
    Expression<String>? fonction,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (schoolYearId != null) 'school_year_id': schoolYearId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (classId != null) 'class_id': classId,
      if (serviceLabel != null) 'service_label': serviceLabel,
      if (fonction != null) 'fonction': fonction,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeacherYearAssignmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? schoolYearId,
    Value<String>? teacherId,
    Value<String?>? classId,
    Value<String?>? serviceLabel,
    Value<String?>? fonction,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return TeacherYearAssignmentsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      schoolYearId: schoolYearId ?? this.schoolYearId,
      teacherId: teacherId ?? this.teacherId,
      classId: classId ?? this.classId,
      serviceLabel: serviceLabel ?? this.serviceLabel,
      fonction: fonction ?? this.fonction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (schoolYearId.present) {
      map['school_year_id'] = Variable<String>(schoolYearId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (serviceLabel.present) {
      map['service_label'] = Variable<String>(serviceLabel.value);
    }
    if (fonction.present) {
      map['fonction'] = Variable<String>(fonction.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeacherYearAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('schoolYearId: $schoolYearId, ')
          ..write('teacherId: $teacherId, ')
          ..write('classId: $classId, ')
          ..write('serviceLabel: $serviceLabel, ')
          ..write('fonction: $fonction, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Students extends Table with TableInfo<Students, StudentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Students(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _firstNamesMeta = const VerificationMeta(
    'firstNames',
  );
  late final GeneratedColumn<String> firstNames = GeneratedColumn<String>(
    'first_names',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _birthPlaceMeta = const VerificationMeta(
    'birthPlace',
  );
  late final GeneratedColumn<String> birthPlace = GeneratedColumn<String>(
    'birth_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _studentCodeMeta = const VerificationMeta(
    'studentCode',
  );
  late final GeneratedColumn<String> studentCode = GeneratedColumn<String>(
    'student_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _registryNumberMeta = const VerificationMeta(
    'registryNumber',
  );
  late final GeneratedColumn<int> registryNumber = GeneratedColumn<int>(
    'registry_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _registryProvisionalMeta =
      const VerificationMeta('registryProvisional');
  late final GeneratedColumn<String> registryProvisional =
      GeneratedColumn<String>(
        'registry_provisional',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _domicileMeta = const VerificationMeta(
    'domicile',
  );
  late final GeneratedColumn<String> domicile = GeneratedColumn<String>(
    'domicile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _entryDateMeta = const VerificationMeta(
    'entryDate',
  );
  late final GeneratedColumn<String> entryDate = GeneratedColumn<String>(
    'entry_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _exitDateMeta = const VerificationMeta(
    'exitDate',
  );
  late final GeneratedColumn<String> exitDate = GeneratedColumn<String>(
    'exit_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _observationsMeta = const VerificationMeta(
    'observations',
  );
  late final GeneratedColumn<String> observations = GeneratedColumn<String>(
    'observations',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _photoUpdatedAtMeta = const VerificationMeta(
    'photoUpdatedAt',
  );
  late final GeneratedColumn<String> photoUpdatedAt = GeneratedColumn<String>(
    'photo_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    lastName,
    firstNames,
    sex,
    birthDate,
    birthPlace,
    studentCode,
    registryNumber,
    registryProvisional,
    domicile,
    entryDate,
    exitDate,
    observations,
    photoPath,
    photoUpdatedAt,
    archivedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('first_names')) {
      context.handle(
        _firstNamesMeta,
        firstNames.isAcceptableOrUnknown(data['first_names']!, _firstNamesMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNamesMeta);
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('birth_place')) {
      context.handle(
        _birthPlaceMeta,
        birthPlace.isAcceptableOrUnknown(data['birth_place']!, _birthPlaceMeta),
      );
    }
    if (data.containsKey('student_code')) {
      context.handle(
        _studentCodeMeta,
        studentCode.isAcceptableOrUnknown(
          data['student_code']!,
          _studentCodeMeta,
        ),
      );
    }
    if (data.containsKey('registry_number')) {
      context.handle(
        _registryNumberMeta,
        registryNumber.isAcceptableOrUnknown(
          data['registry_number']!,
          _registryNumberMeta,
        ),
      );
    }
    if (data.containsKey('registry_provisional')) {
      context.handle(
        _registryProvisionalMeta,
        registryProvisional.isAcceptableOrUnknown(
          data['registry_provisional']!,
          _registryProvisionalMeta,
        ),
      );
    }
    if (data.containsKey('domicile')) {
      context.handle(
        _domicileMeta,
        domicile.isAcceptableOrUnknown(data['domicile']!, _domicileMeta),
      );
    }
    if (data.containsKey('entry_date')) {
      context.handle(
        _entryDateMeta,
        entryDate.isAcceptableOrUnknown(data['entry_date']!, _entryDateMeta),
      );
    }
    if (data.containsKey('exit_date')) {
      context.handle(
        _exitDateMeta,
        exitDate.isAcceptableOrUnknown(data['exit_date']!, _exitDateMeta),
      );
    }
    if (data.containsKey('observations')) {
      context.handle(
        _observationsMeta,
        observations.isAcceptableOrUnknown(
          data['observations']!,
          _observationsMeta,
        ),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('photo_updated_at')) {
      context.handle(
        _photoUpdatedAtMeta,
        photoUpdatedAt.isAcceptableOrUnknown(
          data['photo_updated_at']!,
          _photoUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      firstNames: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_names'],
      )!,
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_date'],
      ),
      birthPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_place'],
      ),
      studentCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_code'],
      ),
      registryNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}registry_number'],
      ),
      registryProvisional: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registry_provisional'],
      ),
      domicile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domicile'],
      ),
      entryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_date'],
      ),
      exitDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exit_date'],
      ),
      observations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observations'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      photoUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_updated_at'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archived_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Students createAlias(String alias) {
    return Students(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class StudentRow extends DataClass implements Insertable<StudentRow> {
  final String id;
  final String schoolId;
  final String lastName;
  final String firstNames;
  final String? sex;
  final String? birthDate;
  final String? birthPlace;
  final String? studentCode;
  final int? registryNumber;
  final String? registryProvisional;
  final String? domicile;
  final String? entryDate;
  final String? exitDate;
  final String? observations;
  final String? photoPath;
  final String? photoUpdatedAt;
  final String? archivedAt;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const StudentRow({
    required this.id,
    required this.schoolId,
    required this.lastName,
    required this.firstNames,
    this.sex,
    this.birthDate,
    this.birthPlace,
    this.studentCode,
    this.registryNumber,
    this.registryProvisional,
    this.domicile,
    this.entryDate,
    this.exitDate,
    this.observations,
    this.photoPath,
    this.photoUpdatedAt,
    this.archivedAt,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['last_name'] = Variable<String>(lastName);
    map['first_names'] = Variable<String>(firstNames);
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<String>(birthDate);
    }
    if (!nullToAbsent || birthPlace != null) {
      map['birth_place'] = Variable<String>(birthPlace);
    }
    if (!nullToAbsent || studentCode != null) {
      map['student_code'] = Variable<String>(studentCode);
    }
    if (!nullToAbsent || registryNumber != null) {
      map['registry_number'] = Variable<int>(registryNumber);
    }
    if (!nullToAbsent || registryProvisional != null) {
      map['registry_provisional'] = Variable<String>(registryProvisional);
    }
    if (!nullToAbsent || domicile != null) {
      map['domicile'] = Variable<String>(domicile);
    }
    if (!nullToAbsent || entryDate != null) {
      map['entry_date'] = Variable<String>(entryDate);
    }
    if (!nullToAbsent || exitDate != null) {
      map['exit_date'] = Variable<String>(exitDate);
    }
    if (!nullToAbsent || observations != null) {
      map['observations'] = Variable<String>(observations);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || photoUpdatedAt != null) {
      map['photo_updated_at'] = Variable<String>(photoUpdatedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(archivedAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      lastName: Value(lastName),
      firstNames: Value(firstNames),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      birthPlace: birthPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(birthPlace),
      studentCode: studentCode == null && nullToAbsent
          ? const Value.absent()
          : Value(studentCode),
      registryNumber: registryNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(registryNumber),
      registryProvisional: registryProvisional == null && nullToAbsent
          ? const Value.absent()
          : Value(registryProvisional),
      domicile: domicile == null && nullToAbsent
          ? const Value.absent()
          : Value(domicile),
      entryDate: entryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(entryDate),
      exitDate: exitDate == null && nullToAbsent
          ? const Value.absent()
          : Value(exitDate),
      observations: observations == null && nullToAbsent
          ? const Value.absent()
          : Value(observations),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      photoUpdatedAt: photoUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUpdatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory StudentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      lastName: serializer.fromJson<String>(json['last_name']),
      firstNames: serializer.fromJson<String>(json['first_names']),
      sex: serializer.fromJson<String?>(json['sex']),
      birthDate: serializer.fromJson<String?>(json['birth_date']),
      birthPlace: serializer.fromJson<String?>(json['birth_place']),
      studentCode: serializer.fromJson<String?>(json['student_code']),
      registryNumber: serializer.fromJson<int?>(json['registry_number']),
      registryProvisional: serializer.fromJson<String?>(
        json['registry_provisional'],
      ),
      domicile: serializer.fromJson<String?>(json['domicile']),
      entryDate: serializer.fromJson<String?>(json['entry_date']),
      exitDate: serializer.fromJson<String?>(json['exit_date']),
      observations: serializer.fromJson<String?>(json['observations']),
      photoPath: serializer.fromJson<String?>(json['photo_path']),
      photoUpdatedAt: serializer.fromJson<String?>(json['photo_updated_at']),
      archivedAt: serializer.fromJson<String?>(json['archived_at']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'last_name': serializer.toJson<String>(lastName),
      'first_names': serializer.toJson<String>(firstNames),
      'sex': serializer.toJson<String?>(sex),
      'birth_date': serializer.toJson<String?>(birthDate),
      'birth_place': serializer.toJson<String?>(birthPlace),
      'student_code': serializer.toJson<String?>(studentCode),
      'registry_number': serializer.toJson<int?>(registryNumber),
      'registry_provisional': serializer.toJson<String?>(registryProvisional),
      'domicile': serializer.toJson<String?>(domicile),
      'entry_date': serializer.toJson<String?>(entryDate),
      'exit_date': serializer.toJson<String?>(exitDate),
      'observations': serializer.toJson<String?>(observations),
      'photo_path': serializer.toJson<String?>(photoPath),
      'photo_updated_at': serializer.toJson<String?>(photoUpdatedAt),
      'archived_at': serializer.toJson<String?>(archivedAt),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  StudentRow copyWith({
    String? id,
    String? schoolId,
    String? lastName,
    String? firstNames,
    Value<String?> sex = const Value.absent(),
    Value<String?> birthDate = const Value.absent(),
    Value<String?> birthPlace = const Value.absent(),
    Value<String?> studentCode = const Value.absent(),
    Value<int?> registryNumber = const Value.absent(),
    Value<String?> registryProvisional = const Value.absent(),
    Value<String?> domicile = const Value.absent(),
    Value<String?> entryDate = const Value.absent(),
    Value<String?> exitDate = const Value.absent(),
    Value<String?> observations = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<String?> photoUpdatedAt = const Value.absent(),
    Value<String?> archivedAt = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => StudentRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    lastName: lastName ?? this.lastName,
    firstNames: firstNames ?? this.firstNames,
    sex: sex.present ? sex.value : this.sex,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    birthPlace: birthPlace.present ? birthPlace.value : this.birthPlace,
    studentCode: studentCode.present ? studentCode.value : this.studentCode,
    registryNumber: registryNumber.present
        ? registryNumber.value
        : this.registryNumber,
    registryProvisional: registryProvisional.present
        ? registryProvisional.value
        : this.registryProvisional,
    domicile: domicile.present ? domicile.value : this.domicile,
    entryDate: entryDate.present ? entryDate.value : this.entryDate,
    exitDate: exitDate.present ? exitDate.value : this.exitDate,
    observations: observations.present ? observations.value : this.observations,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    photoUpdatedAt: photoUpdatedAt.present
        ? photoUpdatedAt.value
        : this.photoUpdatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  StudentRow copyWithCompanion(StudentsCompanion data) {
    return StudentRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      firstNames: data.firstNames.present
          ? data.firstNames.value
          : this.firstNames,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      birthPlace: data.birthPlace.present
          ? data.birthPlace.value
          : this.birthPlace,
      studentCode: data.studentCode.present
          ? data.studentCode.value
          : this.studentCode,
      registryNumber: data.registryNumber.present
          ? data.registryNumber.value
          : this.registryNumber,
      registryProvisional: data.registryProvisional.present
          ? data.registryProvisional.value
          : this.registryProvisional,
      domicile: data.domicile.present ? data.domicile.value : this.domicile,
      entryDate: data.entryDate.present ? data.entryDate.value : this.entryDate,
      exitDate: data.exitDate.present ? data.exitDate.value : this.exitDate,
      observations: data.observations.present
          ? data.observations.value
          : this.observations,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      photoUpdatedAt: data.photoUpdatedAt.present
          ? data.photoUpdatedAt.value
          : this.photoUpdatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('lastName: $lastName, ')
          ..write('firstNames: $firstNames, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('studentCode: $studentCode, ')
          ..write('registryNumber: $registryNumber, ')
          ..write('registryProvisional: $registryProvisional, ')
          ..write('domicile: $domicile, ')
          ..write('entryDate: $entryDate, ')
          ..write('exitDate: $exitDate, ')
          ..write('observations: $observations, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoUpdatedAt: $photoUpdatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    schoolId,
    lastName,
    firstNames,
    sex,
    birthDate,
    birthPlace,
    studentCode,
    registryNumber,
    registryProvisional,
    domicile,
    entryDate,
    exitDate,
    observations,
    photoPath,
    photoUpdatedAt,
    archivedAt,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.lastName == this.lastName &&
          other.firstNames == this.firstNames &&
          other.sex == this.sex &&
          other.birthDate == this.birthDate &&
          other.birthPlace == this.birthPlace &&
          other.studentCode == this.studentCode &&
          other.registryNumber == this.registryNumber &&
          other.registryProvisional == this.registryProvisional &&
          other.domicile == this.domicile &&
          other.entryDate == this.entryDate &&
          other.exitDate == this.exitDate &&
          other.observations == this.observations &&
          other.photoPath == this.photoPath &&
          other.photoUpdatedAt == this.photoUpdatedAt &&
          other.archivedAt == this.archivedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class StudentsCompanion extends UpdateCompanion<StudentRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> lastName;
  final Value<String> firstNames;
  final Value<String?> sex;
  final Value<String?> birthDate;
  final Value<String?> birthPlace;
  final Value<String?> studentCode;
  final Value<int?> registryNumber;
  final Value<String?> registryProvisional;
  final Value<String?> domicile;
  final Value<String?> entryDate;
  final Value<String?> exitDate;
  final Value<String?> observations;
  final Value<String?> photoPath;
  final Value<String?> photoUpdatedAt;
  final Value<String?> archivedAt;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.lastName = const Value.absent(),
    this.firstNames = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.studentCode = const Value.absent(),
    this.registryNumber = const Value.absent(),
    this.registryProvisional = const Value.absent(),
    this.domicile = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.exitDate = const Value.absent(),
    this.observations = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoUpdatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String id,
    required String schoolId,
    required String lastName,
    required String firstNames,
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.studentCode = const Value.absent(),
    this.registryNumber = const Value.absent(),
    this.registryProvisional = const Value.absent(),
    this.domicile = const Value.absent(),
    this.entryDate = const Value.absent(),
    this.exitDate = const Value.absent(),
    this.observations = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.photoUpdatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       lastName = Value(lastName),
       firstNames = Value(firstNames),
       updatedAt = Value(updatedAt);
  static Insertable<StudentRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? lastName,
    Expression<String>? firstNames,
    Expression<String>? sex,
    Expression<String>? birthDate,
    Expression<String>? birthPlace,
    Expression<String>? studentCode,
    Expression<int>? registryNumber,
    Expression<String>? registryProvisional,
    Expression<String>? domicile,
    Expression<String>? entryDate,
    Expression<String>? exitDate,
    Expression<String>? observations,
    Expression<String>? photoPath,
    Expression<String>? photoUpdatedAt,
    Expression<String>? archivedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (lastName != null) 'last_name': lastName,
      if (firstNames != null) 'first_names': firstNames,
      if (sex != null) 'sex': sex,
      if (birthDate != null) 'birth_date': birthDate,
      if (birthPlace != null) 'birth_place': birthPlace,
      if (studentCode != null) 'student_code': studentCode,
      if (registryNumber != null) 'registry_number': registryNumber,
      if (registryProvisional != null)
        'registry_provisional': registryProvisional,
      if (domicile != null) 'domicile': domicile,
      if (entryDate != null) 'entry_date': entryDate,
      if (exitDate != null) 'exit_date': exitDate,
      if (observations != null) 'observations': observations,
      if (photoPath != null) 'photo_path': photoPath,
      if (photoUpdatedAt != null) 'photo_updated_at': photoUpdatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? lastName,
    Value<String>? firstNames,
    Value<String?>? sex,
    Value<String?>? birthDate,
    Value<String?>? birthPlace,
    Value<String?>? studentCode,
    Value<int?>? registryNumber,
    Value<String?>? registryProvisional,
    Value<String?>? domicile,
    Value<String?>? entryDate,
    Value<String?>? exitDate,
    Value<String?>? observations,
    Value<String?>? photoPath,
    Value<String?>? photoUpdatedAt,
    Value<String?>? archivedAt,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      lastName: lastName ?? this.lastName,
      firstNames: firstNames ?? this.firstNames,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      studentCode: studentCode ?? this.studentCode,
      registryNumber: registryNumber ?? this.registryNumber,
      registryProvisional: registryProvisional ?? this.registryProvisional,
      domicile: domicile ?? this.domicile,
      entryDate: entryDate ?? this.entryDate,
      exitDate: exitDate ?? this.exitDate,
      observations: observations ?? this.observations,
      photoPath: photoPath ?? this.photoPath,
      photoUpdatedAt: photoUpdatedAt ?? this.photoUpdatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (firstNames.present) {
      map['first_names'] = Variable<String>(firstNames.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (birthPlace.present) {
      map['birth_place'] = Variable<String>(birthPlace.value);
    }
    if (studentCode.present) {
      map['student_code'] = Variable<String>(studentCode.value);
    }
    if (registryNumber.present) {
      map['registry_number'] = Variable<int>(registryNumber.value);
    }
    if (registryProvisional.present) {
      map['registry_provisional'] = Variable<String>(registryProvisional.value);
    }
    if (domicile.present) {
      map['domicile'] = Variable<String>(domicile.value);
    }
    if (entryDate.present) {
      map['entry_date'] = Variable<String>(entryDate.value);
    }
    if (exitDate.present) {
      map['exit_date'] = Variable<String>(exitDate.value);
    }
    if (observations.present) {
      map['observations'] = Variable<String>(observations.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (photoUpdatedAt.present) {
      map['photo_updated_at'] = Variable<String>(photoUpdatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('lastName: $lastName, ')
          ..write('firstNames: $firstNames, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('studentCode: $studentCode, ')
          ..write('registryNumber: $registryNumber, ')
          ..write('registryProvisional: $registryProvisional, ')
          ..write('domicile: $domicile, ')
          ..write('entryDate: $entryDate, ')
          ..write('exitDate: $exitDate, ')
          ..write('observations: $observations, ')
          ..write('photoPath: $photoPath, ')
          ..write('photoUpdatedAt: $photoUpdatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class StudentRegistry extends Table
    with TableInfo<StudentRegistry, StudentRegistryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  StudentRegistry(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _originSchoolMeta = const VerificationMeta(
    'originSchool',
  );
  late final GeneratedColumn<String> originSchool = GeneratedColumn<String>(
    'origin_school',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _exitReasonMeta = const VerificationMeta(
    'exitReason',
  );
  late final GeneratedColumn<String> exitReason = GeneratedColumn<String>(
    'exit_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _cepDateMeta = const VerificationMeta(
    'cepDate',
  );
  late final GeneratedColumn<String> cepDate = GeneratedColumn<String>(
    'cep_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _diplomasMeta = const VerificationMeta(
    'diplomas',
  );
  late final GeneratedColumn<String> diplomas = GeneratedColumn<String>(
    'diplomas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _directorObservationsMeta =
      const VerificationMeta('directorObservations');
  late final GeneratedColumn<String> directorObservations =
      GeneratedColumn<String>(
        'director_observations',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _registryObservationsMeta =
      const VerificationMeta('registryObservations');
  late final GeneratedColumn<String> registryObservations =
      GeneratedColumn<String>(
        'registry_observations',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _raceMeta = const VerificationMeta('race');
  late final GeneratedColumn<String> race = GeneratedColumn<String>(
    'race',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _religionMeta = const VerificationMeta(
    'religion',
  );
  late final GeneratedColumn<String> religion = GeneratedColumn<String>(
    'religion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    originSchool,
    destination,
    exitReason,
    cepDate,
    diplomas,
    directorObservations,
    registryObservations,
    race,
    religion,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_registry';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentRegistryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('origin_school')) {
      context.handle(
        _originSchoolMeta,
        originSchool.isAcceptableOrUnknown(
          data['origin_school']!,
          _originSchoolMeta,
        ),
      );
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    }
    if (data.containsKey('exit_reason')) {
      context.handle(
        _exitReasonMeta,
        exitReason.isAcceptableOrUnknown(data['exit_reason']!, _exitReasonMeta),
      );
    }
    if (data.containsKey('cep_date')) {
      context.handle(
        _cepDateMeta,
        cepDate.isAcceptableOrUnknown(data['cep_date']!, _cepDateMeta),
      );
    }
    if (data.containsKey('diplomas')) {
      context.handle(
        _diplomasMeta,
        diplomas.isAcceptableOrUnknown(data['diplomas']!, _diplomasMeta),
      );
    }
    if (data.containsKey('director_observations')) {
      context.handle(
        _directorObservationsMeta,
        directorObservations.isAcceptableOrUnknown(
          data['director_observations']!,
          _directorObservationsMeta,
        ),
      );
    }
    if (data.containsKey('registry_observations')) {
      context.handle(
        _registryObservationsMeta,
        registryObservations.isAcceptableOrUnknown(
          data['registry_observations']!,
          _registryObservationsMeta,
        ),
      );
    }
    if (data.containsKey('race')) {
      context.handle(
        _raceMeta,
        race.isAcceptableOrUnknown(data['race']!, _raceMeta),
      );
    }
    if (data.containsKey('religion')) {
      context.handle(
        _religionMeta,
        religion.isAcceptableOrUnknown(data['religion']!, _religionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentRegistryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentRegistryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      originSchool: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_school'],
      ),
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      ),
      exitReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exit_reason'],
      ),
      cepDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cep_date'],
      ),
      diplomas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diplomas'],
      ),
      directorObservations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}director_observations'],
      ),
      registryObservations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registry_observations'],
      ),
      race: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}race'],
      ),
      religion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}religion'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  StudentRegistry createAlias(String alias) {
    return StudentRegistry(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class StudentRegistryRow extends DataClass
    implements Insertable<StudentRegistryRow> {
  final String id;
  final String schoolId;
  final String? originSchool;
  final String? destination;
  final String? exitReason;
  final String? cepDate;
  final String? diplomas;
  final String? directorObservations;
  final String? registryObservations;
  final String? race;
  final String? religion;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const StudentRegistryRow({
    required this.id,
    required this.schoolId,
    this.originSchool,
    this.destination,
    this.exitReason,
    this.cepDate,
    this.diplomas,
    this.directorObservations,
    this.registryObservations,
    this.race,
    this.religion,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    if (!nullToAbsent || originSchool != null) {
      map['origin_school'] = Variable<String>(originSchool);
    }
    if (!nullToAbsent || destination != null) {
      map['destination'] = Variable<String>(destination);
    }
    if (!nullToAbsent || exitReason != null) {
      map['exit_reason'] = Variable<String>(exitReason);
    }
    if (!nullToAbsent || cepDate != null) {
      map['cep_date'] = Variable<String>(cepDate);
    }
    if (!nullToAbsent || diplomas != null) {
      map['diplomas'] = Variable<String>(diplomas);
    }
    if (!nullToAbsent || directorObservations != null) {
      map['director_observations'] = Variable<String>(directorObservations);
    }
    if (!nullToAbsent || registryObservations != null) {
      map['registry_observations'] = Variable<String>(registryObservations);
    }
    if (!nullToAbsent || race != null) {
      map['race'] = Variable<String>(race);
    }
    if (!nullToAbsent || religion != null) {
      map['religion'] = Variable<String>(religion);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  StudentRegistryCompanion toCompanion(bool nullToAbsent) {
    return StudentRegistryCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      originSchool: originSchool == null && nullToAbsent
          ? const Value.absent()
          : Value(originSchool),
      destination: destination == null && nullToAbsent
          ? const Value.absent()
          : Value(destination),
      exitReason: exitReason == null && nullToAbsent
          ? const Value.absent()
          : Value(exitReason),
      cepDate: cepDate == null && nullToAbsent
          ? const Value.absent()
          : Value(cepDate),
      diplomas: diplomas == null && nullToAbsent
          ? const Value.absent()
          : Value(diplomas),
      directorObservations: directorObservations == null && nullToAbsent
          ? const Value.absent()
          : Value(directorObservations),
      registryObservations: registryObservations == null && nullToAbsent
          ? const Value.absent()
          : Value(registryObservations),
      race: race == null && nullToAbsent ? const Value.absent() : Value(race),
      religion: religion == null && nullToAbsent
          ? const Value.absent()
          : Value(religion),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory StudentRegistryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentRegistryRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      originSchool: serializer.fromJson<String?>(json['origin_school']),
      destination: serializer.fromJson<String?>(json['destination']),
      exitReason: serializer.fromJson<String?>(json['exit_reason']),
      cepDate: serializer.fromJson<String?>(json['cep_date']),
      diplomas: serializer.fromJson<String?>(json['diplomas']),
      directorObservations: serializer.fromJson<String?>(
        json['director_observations'],
      ),
      registryObservations: serializer.fromJson<String?>(
        json['registry_observations'],
      ),
      race: serializer.fromJson<String?>(json['race']),
      religion: serializer.fromJson<String?>(json['religion']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'origin_school': serializer.toJson<String?>(originSchool),
      'destination': serializer.toJson<String?>(destination),
      'exit_reason': serializer.toJson<String?>(exitReason),
      'cep_date': serializer.toJson<String?>(cepDate),
      'diplomas': serializer.toJson<String?>(diplomas),
      'director_observations': serializer.toJson<String?>(directorObservations),
      'registry_observations': serializer.toJson<String?>(registryObservations),
      'race': serializer.toJson<String?>(race),
      'religion': serializer.toJson<String?>(religion),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  StudentRegistryRow copyWith({
    String? id,
    String? schoolId,
    Value<String?> originSchool = const Value.absent(),
    Value<String?> destination = const Value.absent(),
    Value<String?> exitReason = const Value.absent(),
    Value<String?> cepDate = const Value.absent(),
    Value<String?> diplomas = const Value.absent(),
    Value<String?> directorObservations = const Value.absent(),
    Value<String?> registryObservations = const Value.absent(),
    Value<String?> race = const Value.absent(),
    Value<String?> religion = const Value.absent(),
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => StudentRegistryRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    originSchool: originSchool.present ? originSchool.value : this.originSchool,
    destination: destination.present ? destination.value : this.destination,
    exitReason: exitReason.present ? exitReason.value : this.exitReason,
    cepDate: cepDate.present ? cepDate.value : this.cepDate,
    diplomas: diplomas.present ? diplomas.value : this.diplomas,
    directorObservations: directorObservations.present
        ? directorObservations.value
        : this.directorObservations,
    registryObservations: registryObservations.present
        ? registryObservations.value
        : this.registryObservations,
    race: race.present ? race.value : this.race,
    religion: religion.present ? religion.value : this.religion,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  StudentRegistryRow copyWithCompanion(StudentRegistryCompanion data) {
    return StudentRegistryRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      originSchool: data.originSchool.present
          ? data.originSchool.value
          : this.originSchool,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      exitReason: data.exitReason.present
          ? data.exitReason.value
          : this.exitReason,
      cepDate: data.cepDate.present ? data.cepDate.value : this.cepDate,
      diplomas: data.diplomas.present ? data.diplomas.value : this.diplomas,
      directorObservations: data.directorObservations.present
          ? data.directorObservations.value
          : this.directorObservations,
      registryObservations: data.registryObservations.present
          ? data.registryObservations.value
          : this.registryObservations,
      race: data.race.present ? data.race.value : this.race,
      religion: data.religion.present ? data.religion.value : this.religion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentRegistryRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('originSchool: $originSchool, ')
          ..write('destination: $destination, ')
          ..write('exitReason: $exitReason, ')
          ..write('cepDate: $cepDate, ')
          ..write('diplomas: $diplomas, ')
          ..write('directorObservations: $directorObservations, ')
          ..write('registryObservations: $registryObservations, ')
          ..write('race: $race, ')
          ..write('religion: $religion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    originSchool,
    destination,
    exitReason,
    cepDate,
    diplomas,
    directorObservations,
    registryObservations,
    race,
    religion,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentRegistryRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.originSchool == this.originSchool &&
          other.destination == this.destination &&
          other.exitReason == this.exitReason &&
          other.cepDate == this.cepDate &&
          other.diplomas == this.diplomas &&
          other.directorObservations == this.directorObservations &&
          other.registryObservations == this.registryObservations &&
          other.race == this.race &&
          other.religion == this.religion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class StudentRegistryCompanion extends UpdateCompanion<StudentRegistryRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String?> originSchool;
  final Value<String?> destination;
  final Value<String?> exitReason;
  final Value<String?> cepDate;
  final Value<String?> diplomas;
  final Value<String?> directorObservations;
  final Value<String?> registryObservations;
  final Value<String?> race;
  final Value<String?> religion;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const StudentRegistryCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.originSchool = const Value.absent(),
    this.destination = const Value.absent(),
    this.exitReason = const Value.absent(),
    this.cepDate = const Value.absent(),
    this.diplomas = const Value.absent(),
    this.directorObservations = const Value.absent(),
    this.registryObservations = const Value.absent(),
    this.race = const Value.absent(),
    this.religion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentRegistryCompanion.insert({
    required String id,
    required String schoolId,
    this.originSchool = const Value.absent(),
    this.destination = const Value.absent(),
    this.exitReason = const Value.absent(),
    this.cepDate = const Value.absent(),
    this.diplomas = const Value.absent(),
    this.directorObservations = const Value.absent(),
    this.registryObservations = const Value.absent(),
    this.race = const Value.absent(),
    this.religion = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       updatedAt = Value(updatedAt);
  static Insertable<StudentRegistryRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? originSchool,
    Expression<String>? destination,
    Expression<String>? exitReason,
    Expression<String>? cepDate,
    Expression<String>? diplomas,
    Expression<String>? directorObservations,
    Expression<String>? registryObservations,
    Expression<String>? race,
    Expression<String>? religion,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (originSchool != null) 'origin_school': originSchool,
      if (destination != null) 'destination': destination,
      if (exitReason != null) 'exit_reason': exitReason,
      if (cepDate != null) 'cep_date': cepDate,
      if (diplomas != null) 'diplomas': diplomas,
      if (directorObservations != null)
        'director_observations': directorObservations,
      if (registryObservations != null)
        'registry_observations': registryObservations,
      if (race != null) 'race': race,
      if (religion != null) 'religion': religion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentRegistryCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String?>? originSchool,
    Value<String?>? destination,
    Value<String?>? exitReason,
    Value<String?>? cepDate,
    Value<String?>? diplomas,
    Value<String?>? directorObservations,
    Value<String?>? registryObservations,
    Value<String?>? race,
    Value<String?>? religion,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return StudentRegistryCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      originSchool: originSchool ?? this.originSchool,
      destination: destination ?? this.destination,
      exitReason: exitReason ?? this.exitReason,
      cepDate: cepDate ?? this.cepDate,
      diplomas: diplomas ?? this.diplomas,
      directorObservations: directorObservations ?? this.directorObservations,
      registryObservations: registryObservations ?? this.registryObservations,
      race: race ?? this.race,
      religion: religion ?? this.religion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (originSchool.present) {
      map['origin_school'] = Variable<String>(originSchool.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (exitReason.present) {
      map['exit_reason'] = Variable<String>(exitReason.value);
    }
    if (cepDate.present) {
      map['cep_date'] = Variable<String>(cepDate.value);
    }
    if (diplomas.present) {
      map['diplomas'] = Variable<String>(diplomas.value);
    }
    if (directorObservations.present) {
      map['director_observations'] = Variable<String>(
        directorObservations.value,
      );
    }
    if (registryObservations.present) {
      map['registry_observations'] = Variable<String>(
        registryObservations.value,
      );
    }
    if (race.present) {
      map['race'] = Variable<String>(race.value);
    }
    if (religion.present) {
      map['religion'] = Variable<String>(religion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentRegistryCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('originSchool: $originSchool, ')
          ..write('destination: $destination, ')
          ..write('exitReason: $exitReason, ')
          ..write('cepDate: $cepDate, ')
          ..write('diplomas: $diplomas, ')
          ..write('directorObservations: $directorObservations, ')
          ..write('registryObservations: $registryObservations, ')
          ..write('race: $race, ')
          ..write('religion: $religion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Guardians extends Table with TableInfo<Guardians, GuardianRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Guardians(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _professionMeta = const VerificationMeta(
    'profession',
  );
  late final GeneratedColumn<String> profession = GeneratedColumn<String>(
    'profession',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _domicileMeta = const VerificationMeta(
    'domicile',
  );
  late final GeneratedColumn<String> domicile = GeneratedColumn<String>(
    'domicile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isLodgerMeta = const VerificationMeta(
    'isLodger',
  );
  late final GeneratedColumn<bool> isLodger = GeneratedColumn<bool>(
    'is_lodger',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    studentId,
    relation,
    fullName,
    profession,
    domicile,
    address,
    phone,
    isLodger,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guardians';
  @override
  VerificationContext validateIntegrity(
    Insertable<GuardianRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    } else if (isInserting) {
      context.missing(_relationMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('profession')) {
      context.handle(
        _professionMeta,
        profession.isAcceptableOrUnknown(data['profession']!, _professionMeta),
      );
    }
    if (data.containsKey('domicile')) {
      context.handle(
        _domicileMeta,
        domicile.isAcceptableOrUnknown(data['domicile']!, _domicileMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('is_lodger')) {
      context.handle(
        _isLodgerMeta,
        isLodger.isAcceptableOrUnknown(data['is_lodger']!, _isLodgerMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GuardianRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GuardianRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      profession: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profession'],
      ),
      domicile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domicile'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      isLodger: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_lodger'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Guardians createAlias(String alias) {
    return Guardians(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class GuardianRow extends DataClass implements Insertable<GuardianRow> {
  final String id;
  final String schoolId;
  final String studentId;
  final String relation;
  final String fullName;
  final String? profession;
  final String? domicile;
  final String? address;
  final String? phone;
  final bool isLodger;
  final int sortOrder;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const GuardianRow({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.relation,
    required this.fullName,
    this.profession,
    this.domicile,
    this.address,
    this.phone,
    required this.isLodger,
    required this.sortOrder,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['relation'] = Variable<String>(relation);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || profession != null) {
      map['profession'] = Variable<String>(profession);
    }
    if (!nullToAbsent || domicile != null) {
      map['domicile'] = Variable<String>(domicile);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['is_lodger'] = Variable<bool>(isLodger);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  GuardiansCompanion toCompanion(bool nullToAbsent) {
    return GuardiansCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      relation: Value(relation),
      fullName: Value(fullName),
      profession: profession == null && nullToAbsent
          ? const Value.absent()
          : Value(profession),
      domicile: domicile == null && nullToAbsent
          ? const Value.absent()
          : Value(domicile),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      isLodger: Value(isLodger),
      sortOrder: Value(sortOrder),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory GuardianRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GuardianRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      relation: serializer.fromJson<String>(json['relation']),
      fullName: serializer.fromJson<String>(json['full_name']),
      profession: serializer.fromJson<String?>(json['profession']),
      domicile: serializer.fromJson<String?>(json['domicile']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      isLodger: serializer.fromJson<bool>(json['is_lodger']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'student_id': serializer.toJson<String>(studentId),
      'relation': serializer.toJson<String>(relation),
      'full_name': serializer.toJson<String>(fullName),
      'profession': serializer.toJson<String?>(profession),
      'domicile': serializer.toJson<String?>(domicile),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'is_lodger': serializer.toJson<bool>(isLodger),
      'sort_order': serializer.toJson<int>(sortOrder),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  GuardianRow copyWith({
    String? id,
    String? schoolId,
    String? studentId,
    String? relation,
    String? fullName,
    Value<String?> profession = const Value.absent(),
    Value<String?> domicile = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    bool? isLodger,
    int? sortOrder,
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => GuardianRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    relation: relation ?? this.relation,
    fullName: fullName ?? this.fullName,
    profession: profession.present ? profession.value : this.profession,
    domicile: domicile.present ? domicile.value : this.domicile,
    address: address.present ? address.value : this.address,
    phone: phone.present ? phone.value : this.phone,
    isLodger: isLodger ?? this.isLodger,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  GuardianRow copyWithCompanion(GuardiansCompanion data) {
    return GuardianRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      relation: data.relation.present ? data.relation.value : this.relation,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      profession: data.profession.present
          ? data.profession.value
          : this.profession,
      domicile: data.domicile.present ? data.domicile.value : this.domicile,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      isLodger: data.isLodger.present ? data.isLodger.value : this.isLodger,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GuardianRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('relation: $relation, ')
          ..write('fullName: $fullName, ')
          ..write('profession: $profession, ')
          ..write('domicile: $domicile, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('isLodger: $isLodger, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    studentId,
    relation,
    fullName,
    profession,
    domicile,
    address,
    phone,
    isLodger,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuardianRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.relation == this.relation &&
          other.fullName == this.fullName &&
          other.profession == this.profession &&
          other.domicile == this.domicile &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.isLodger == this.isLodger &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class GuardiansCompanion extends UpdateCompanion<GuardianRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> relation;
  final Value<String> fullName;
  final Value<String?> profession;
  final Value<String?> domicile;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<bool> isLodger;
  final Value<int> sortOrder;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const GuardiansCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.relation = const Value.absent(),
    this.fullName = const Value.absent(),
    this.profession = const Value.absent(),
    this.domicile = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.isLodger = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GuardiansCompanion.insert({
    required String id,
    required String schoolId,
    required String studentId,
    required String relation,
    required String fullName,
    this.profession = const Value.absent(),
    this.domicile = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.isLodger = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       studentId = Value(studentId),
       relation = Value(relation),
       fullName = Value(fullName),
       updatedAt = Value(updatedAt);
  static Insertable<GuardianRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? relation,
    Expression<String>? fullName,
    Expression<String>? profession,
    Expression<String>? domicile,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<bool>? isLodger,
    Expression<int>? sortOrder,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (relation != null) 'relation': relation,
      if (fullName != null) 'full_name': fullName,
      if (profession != null) 'profession': profession,
      if (domicile != null) 'domicile': domicile,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (isLodger != null) 'is_lodger': isLodger,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GuardiansCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String>? relation,
    Value<String>? fullName,
    Value<String?>? profession,
    Value<String?>? domicile,
    Value<String?>? address,
    Value<String?>? phone,
    Value<bool>? isLodger,
    Value<int>? sortOrder,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return GuardiansCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      relation: relation ?? this.relation,
      fullName: fullName ?? this.fullName,
      profession: profession ?? this.profession,
      domicile: domicile ?? this.domicile,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isLodger: isLodger ?? this.isLodger,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (profession.present) {
      map['profession'] = Variable<String>(profession.value);
    }
    if (domicile.present) {
      map['domicile'] = Variable<String>(domicile.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (isLodger.present) {
      map['is_lodger'] = Variable<bool>(isLodger.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuardiansCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('relation: $relation, ')
          ..write('fullName: $fullName, ')
          ..write('profession: $profession, ')
          ..write('domicile: $domicile, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('isLodger: $isLodger, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Enrollments extends Table with TableInfo<Enrollments, EnrollmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Enrollments(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _schoolYearIdMeta = const VerificationMeta(
    'schoolYearId',
  );
  late final GeneratedColumn<String> schoolYearId = GeneratedColumn<String>(
    'school_year_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _levelCodeMeta = const VerificationMeta(
    'levelCode',
  );
  late final GeneratedColumn<String> levelCode = GeneratedColumn<String>(
    'level_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  late final GeneratedColumn<String> startsOn = GeneratedColumn<String>(
    'starts_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  late final GeneratedColumn<String> endsOn = GeneratedColumn<String>(
    'ends_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _endReasonMeta = const VerificationMeta(
    'endReason',
  );
  late final GeneratedColumn<String> endReason = GeneratedColumn<String>(
    'end_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isRepeatMeta = const VerificationMeta(
    'isRepeat',
  );
  late final GeneratedColumn<bool> isRepeat = GeneratedColumn<bool>(
    'is_repeat',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schoolId,
    studentId,
    classId,
    schoolYearId,
    levelCode,
    startsOn,
    endsOn,
    endReason,
    isRepeat,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'enrollments';
  @override
  VerificationContext validateIntegrity(
    Insertable<EnrollmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('school_year_id')) {
      context.handle(
        _schoolYearIdMeta,
        schoolYearId.isAcceptableOrUnknown(
          data['school_year_id']!,
          _schoolYearIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schoolYearIdMeta);
    }
    if (data.containsKey('level_code')) {
      context.handle(
        _levelCodeMeta,
        levelCode.isAcceptableOrUnknown(data['level_code']!, _levelCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_levelCodeMeta);
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    }
    if (data.containsKey('end_reason')) {
      context.handle(
        _endReasonMeta,
        endReason.isAcceptableOrUnknown(data['end_reason']!, _endReasonMeta),
      );
    }
    if (data.containsKey('is_repeat')) {
      context.handle(
        _isRepeatMeta,
        isRepeat.isAcceptableOrUnknown(data['is_repeat']!, _isRepeatMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EnrollmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EnrollmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      schoolYearId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_year_id'],
      )!,
      levelCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_code'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}starts_on'],
      ),
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ends_on'],
      ),
      endReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_reason'],
      ),
      isRepeat: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_repeat'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  Enrollments createAlias(String alias) {
    return Enrollments(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class EnrollmentRow extends DataClass implements Insertable<EnrollmentRow> {
  final String id;
  final String schoolId;
  final String studentId;
  final String classId;
  final String schoolYearId;
  final String levelCode;
  final String? startsOn;
  final String? endsOn;
  final String? endReason;
  final bool isRepeat;
  final String? createdAt;
  final String updatedAt;
  final String? deletedAt;
  final String? syncedAt;
  const EnrollmentRow({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.classId,
    required this.schoolYearId,
    required this.levelCode,
    this.startsOn,
    this.endsOn,
    this.endReason,
    required this.isRepeat,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['class_id'] = Variable<String>(classId);
    map['school_year_id'] = Variable<String>(schoolYearId);
    map['level_code'] = Variable<String>(levelCode);
    if (!nullToAbsent || startsOn != null) {
      map['starts_on'] = Variable<String>(startsOn);
    }
    if (!nullToAbsent || endsOn != null) {
      map['ends_on'] = Variable<String>(endsOn);
    }
    if (!nullToAbsent || endReason != null) {
      map['end_reason'] = Variable<String>(endReason);
    }
    map['is_repeat'] = Variable<bool>(isRepeat);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<String>(syncedAt);
    }
    return map;
  }

  EnrollmentsCompanion toCompanion(bool nullToAbsent) {
    return EnrollmentsCompanion(
      id: Value(id),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      classId: Value(classId),
      schoolYearId: Value(schoolYearId),
      levelCode: Value(levelCode),
      startsOn: startsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(startsOn),
      endsOn: endsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endsOn),
      endReason: endReason == null && nullToAbsent
          ? const Value.absent()
          : Value(endReason),
      isRepeat: Value(isRepeat),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory EnrollmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EnrollmentRow(
      id: serializer.fromJson<String>(json['id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      studentId: serializer.fromJson<String>(json['student_id']),
      classId: serializer.fromJson<String>(json['class_id']),
      schoolYearId: serializer.fromJson<String>(json['school_year_id']),
      levelCode: serializer.fromJson<String>(json['level_code']),
      startsOn: serializer.fromJson<String?>(json['starts_on']),
      endsOn: serializer.fromJson<String?>(json['ends_on']),
      endReason: serializer.fromJson<String?>(json['end_reason']),
      isRepeat: serializer.fromJson<bool>(json['is_repeat']),
      createdAt: serializer.fromJson<String?>(json['created_at']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
      deletedAt: serializer.fromJson<String?>(json['deleted_at']),
      syncedAt: serializer.fromJson<String?>(json['synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'school_id': serializer.toJson<String>(schoolId),
      'student_id': serializer.toJson<String>(studentId),
      'class_id': serializer.toJson<String>(classId),
      'school_year_id': serializer.toJson<String>(schoolYearId),
      'level_code': serializer.toJson<String>(levelCode),
      'starts_on': serializer.toJson<String?>(startsOn),
      'ends_on': serializer.toJson<String?>(endsOn),
      'end_reason': serializer.toJson<String?>(endReason),
      'is_repeat': serializer.toJson<bool>(isRepeat),
      'created_at': serializer.toJson<String?>(createdAt),
      'updated_at': serializer.toJson<String>(updatedAt),
      'deleted_at': serializer.toJson<String?>(deletedAt),
      'synced_at': serializer.toJson<String?>(syncedAt),
    };
  }

  EnrollmentRow copyWith({
    String? id,
    String? schoolId,
    String? studentId,
    String? classId,
    String? schoolYearId,
    String? levelCode,
    Value<String?> startsOn = const Value.absent(),
    Value<String?> endsOn = const Value.absent(),
    Value<String?> endReason = const Value.absent(),
    bool? isRepeat,
    Value<String?> createdAt = const Value.absent(),
    String? updatedAt,
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> syncedAt = const Value.absent(),
  }) => EnrollmentRow(
    id: id ?? this.id,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    classId: classId ?? this.classId,
    schoolYearId: schoolYearId ?? this.schoolYearId,
    levelCode: levelCode ?? this.levelCode,
    startsOn: startsOn.present ? startsOn.value : this.startsOn,
    endsOn: endsOn.present ? endsOn.value : this.endsOn,
    endReason: endReason.present ? endReason.value : this.endReason,
    isRepeat: isRepeat ?? this.isRepeat,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  EnrollmentRow copyWithCompanion(EnrollmentsCompanion data) {
    return EnrollmentRow(
      id: data.id.present ? data.id.value : this.id,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      classId: data.classId.present ? data.classId.value : this.classId,
      schoolYearId: data.schoolYearId.present
          ? data.schoolYearId.value
          : this.schoolYearId,
      levelCode: data.levelCode.present ? data.levelCode.value : this.levelCode,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      endReason: data.endReason.present ? data.endReason.value : this.endReason,
      isRepeat: data.isRepeat.present ? data.isRepeat.value : this.isRepeat,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EnrollmentRow(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('classId: $classId, ')
          ..write('schoolYearId: $schoolYearId, ')
          ..write('levelCode: $levelCode, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('endReason: $endReason, ')
          ..write('isRepeat: $isRepeat, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schoolId,
    studentId,
    classId,
    schoolYearId,
    levelCode,
    startsOn,
    endsOn,
    endReason,
    isRepeat,
    createdAt,
    updatedAt,
    deletedAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EnrollmentRow &&
          other.id == this.id &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.classId == this.classId &&
          other.schoolYearId == this.schoolYearId &&
          other.levelCode == this.levelCode &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.endReason == this.endReason &&
          other.isRepeat == this.isRepeat &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncedAt == this.syncedAt);
}

class EnrollmentsCompanion extends UpdateCompanion<EnrollmentRow> {
  final Value<String> id;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> classId;
  final Value<String> schoolYearId;
  final Value<String> levelCode;
  final Value<String?> startsOn;
  final Value<String?> endsOn;
  final Value<String?> endReason;
  final Value<bool> isRepeat;
  final Value<String?> createdAt;
  final Value<String> updatedAt;
  final Value<String?> deletedAt;
  final Value<String?> syncedAt;
  final Value<int> rowid;
  const EnrollmentsCompanion({
    this.id = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.classId = const Value.absent(),
    this.schoolYearId = const Value.absent(),
    this.levelCode = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.endReason = const Value.absent(),
    this.isRepeat = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnrollmentsCompanion.insert({
    required String id,
    required String schoolId,
    required String studentId,
    required String classId,
    required String schoolYearId,
    required String levelCode,
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.endReason = const Value.absent(),
    this.isRepeat = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       schoolId = Value(schoolId),
       studentId = Value(studentId),
       classId = Value(classId),
       schoolYearId = Value(schoolYearId),
       levelCode = Value(levelCode),
       updatedAt = Value(updatedAt);
  static Insertable<EnrollmentRow> custom({
    Expression<String>? id,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? classId,
    Expression<String>? schoolYearId,
    Expression<String>? levelCode,
    Expression<String>? startsOn,
    Expression<String>? endsOn,
    Expression<String>? endReason,
    Expression<bool>? isRepeat,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
    Expression<String>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (classId != null) 'class_id': classId,
      if (schoolYearId != null) 'school_year_id': schoolYearId,
      if (levelCode != null) 'level_code': levelCode,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (endReason != null) 'end_reason': endReason,
      if (isRepeat != null) 'is_repeat': isRepeat,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnrollmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String>? classId,
    Value<String>? schoolYearId,
    Value<String>? levelCode,
    Value<String?>? startsOn,
    Value<String?>? endsOn,
    Value<String?>? endReason,
    Value<bool>? isRepeat,
    Value<String?>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? deletedAt,
    Value<String?>? syncedAt,
    Value<int>? rowid,
  }) {
    return EnrollmentsCompanion(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      schoolYearId: schoolYearId ?? this.schoolYearId,
      levelCode: levelCode ?? this.levelCode,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      endReason: endReason ?? this.endReason,
      isRepeat: isRepeat ?? this.isRepeat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (schoolYearId.present) {
      map['school_year_id'] = Variable<String>(schoolYearId.value);
    }
    if (levelCode.present) {
      map['level_code'] = Variable<String>(levelCode.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<String>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<String>(endsOn.value);
    }
    if (endReason.present) {
      map['end_reason'] = Variable<String>(endReason.value);
    }
    if (isRepeat.present) {
      map['is_repeat'] = Variable<bool>(isRepeat.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnrollmentsCompanion(')
          ..write('id: $id, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('classId: $classId, ')
          ..write('schoolYearId: $schoolYearId, ')
          ..write('levelCode: $levelCode, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('endReason: $endReason, ')
          ..write('isRepeat: $isRepeat, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Outbox extends Table with TableInfo<Outbox, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Outbox(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _rowKeyMeta = const VerificationMeta('rowKey');
  late final GeneratedColumn<String> rowKey = GeneratedColumn<String>(
    'row_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'en_attente\'',
    defaultValue: const CustomExpression('\'en_attente\''),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetTable,
    rowKey,
    payload,
    revision,
    status,
    message,
    attempts,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('row_key')) {
      context.handle(
        _rowKeyMeta,
        rowKey.isAcceptableOrUnknown(data['row_key']!, _rowKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_rowKeyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      rowKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  Outbox createAlias(String alias) {
    return Outbox(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final int id;
  final String targetTable;
  final String rowKey;
  final String payload;
  final int revision;
  final String status;
  final String? message;
  final int attempts;
  final String createdAt;
  const OutboxEntry({
    required this.id,
    required this.targetTable,
    required this.rowKey,
    required this.payload,
    required this.revision,
    required this.status,
    this.message,
    required this.attempts,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_table'] = Variable<String>(targetTable);
    map['row_key'] = Variable<String>(rowKey);
    map['payload'] = Variable<String>(payload);
    map['revision'] = Variable<int>(revision);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      targetTable: Value(targetTable),
      rowKey: Value(rowKey),
      payload: Value(payload),
      revision: Value(revision),
      status: Value(status),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      id: serializer.fromJson<int>(json['id']),
      targetTable: serializer.fromJson<String>(json['target_table']),
      rowKey: serializer.fromJson<String>(json['row_key']),
      payload: serializer.fromJson<String>(json['payload']),
      revision: serializer.fromJson<int>(json['revision']),
      status: serializer.fromJson<String>(json['status']),
      message: serializer.fromJson<String?>(json['message']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<String>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'target_table': serializer.toJson<String>(targetTable),
      'row_key': serializer.toJson<String>(rowKey),
      'payload': serializer.toJson<String>(payload),
      'revision': serializer.toJson<int>(revision),
      'status': serializer.toJson<String>(status),
      'message': serializer.toJson<String?>(message),
      'attempts': serializer.toJson<int>(attempts),
      'created_at': serializer.toJson<String>(createdAt),
    };
  }

  OutboxEntry copyWith({
    int? id,
    String? targetTable,
    String? rowKey,
    String? payload,
    int? revision,
    String? status,
    Value<String?> message = const Value.absent(),
    int? attempts,
    String? createdAt,
  }) => OutboxEntry(
    id: id ?? this.id,
    targetTable: targetTable ?? this.targetTable,
    rowKey: rowKey ?? this.rowKey,
    payload: payload ?? this.payload,
    revision: revision ?? this.revision,
    status: status ?? this.status,
    message: message.present ? message.value : this.message,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxEntry copyWithCompanion(OutboxCompanion data) {
    return OutboxEntry(
      id: data.id.present ? data.id.value : this.id,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      rowKey: data.rowKey.present ? data.rowKey.value : this.rowKey,
      payload: data.payload.present ? data.payload.value : this.payload,
      revision: data.revision.present ? data.revision.value : this.revision,
      status: data.status.present ? data.status.value : this.status,
      message: data.message.present ? data.message.value : this.message,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowKey: $rowKey, ')
          ..write('payload: $payload, ')
          ..write('revision: $revision, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetTable,
    rowKey,
    payload,
    revision,
    status,
    message,
    attempts,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.id == this.id &&
          other.targetTable == this.targetTable &&
          other.rowKey == this.rowKey &&
          other.payload == this.payload &&
          other.revision == this.revision &&
          other.status == this.status &&
          other.message == this.message &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt);
}

class OutboxCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<int> id;
  final Value<String> targetTable;
  final Value<String> rowKey;
  final Value<String> payload;
  final Value<int> revision;
  final Value<String> status;
  final Value<String?> message;
  final Value<int> attempts;
  final Value<String> createdAt;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.rowKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.revision = const Value.absent(),
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.id = const Value.absent(),
    required String targetTable,
    required String rowKey,
    required String payload,
    this.revision = const Value.absent(),
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.attempts = const Value.absent(),
    required String createdAt,
  }) : targetTable = Value(targetTable),
       rowKey = Value(rowKey),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxEntry> custom({
    Expression<int>? id,
    Expression<String>? targetTable,
    Expression<String>? rowKey,
    Expression<String>? payload,
    Expression<int>? revision,
    Expression<String>? status,
    Expression<String>? message,
    Expression<int>? attempts,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetTable != null) 'target_table': targetTable,
      if (rowKey != null) 'row_key': rowKey,
      if (payload != null) 'payload': payload,
      if (revision != null) 'revision': revision,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? id,
    Value<String>? targetTable,
    Value<String>? rowKey,
    Value<String>? payload,
    Value<int>? revision,
    Value<String>? status,
    Value<String?>? message,
    Value<int>? attempts,
    Value<String>? createdAt,
  }) {
    return OutboxCompanion(
      id: id ?? this.id,
      targetTable: targetTable ?? this.targetTable,
      rowKey: rowKey ?? this.rowKey,
      payload: payload ?? this.payload,
      revision: revision ?? this.revision,
      status: status ?? this.status,
      message: message ?? this.message,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (rowKey.present) {
      map['row_key'] = Variable<String>(rowKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('targetTable: $targetTable, ')
          ..write('rowKey: $rowKey, ')
          ..write('payload: $payload, ')
          ..write('revision: $revision, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class SyncCursors extends Table with TableInfo<SyncCursors, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SyncCursors(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  late final GeneratedColumn<String> syncedAt = GeneratedColumn<String>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tieMeta = const VerificationMeta('tie');
  late final GeneratedColumn<String> tie = GeneratedColumn<String>(
    'tie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  @override
  List<GeneratedColumn> get $columns => [targetTable, syncedAt, tie];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_syncedAtMeta);
    }
    if (data.containsKey('tie')) {
      context.handle(
        _tieMeta,
        tie.isAcceptableOrUnknown(data['tie']!, _tieMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {targetTable};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}synced_at'],
      )!,
      tie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tie'],
      )!,
    );
  }

  @override
  SyncCursors createAlias(String alias) {
    return SyncCursors(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String targetTable;
  final String syncedAt;
  final String tie;
  const SyncCursor({
    required this.targetTable,
    required this.syncedAt,
    required this.tie,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['target_table'] = Variable<String>(targetTable);
    map['synced_at'] = Variable<String>(syncedAt);
    map['tie'] = Variable<String>(tie);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      targetTable: Value(targetTable),
      syncedAt: Value(syncedAt),
      tie: Value(tie),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      targetTable: serializer.fromJson<String>(json['target_table']),
      syncedAt: serializer.fromJson<String>(json['synced_at']),
      tie: serializer.fromJson<String>(json['tie']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'target_table': serializer.toJson<String>(targetTable),
      'synced_at': serializer.toJson<String>(syncedAt),
      'tie': serializer.toJson<String>(tie),
    };
  }

  SyncCursor copyWith({String? targetTable, String? syncedAt, String? tie}) =>
      SyncCursor(
        targetTable: targetTable ?? this.targetTable,
        syncedAt: syncedAt ?? this.syncedAt,
        tie: tie ?? this.tie,
      );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      tie: data.tie.present ? data.tie.value : this.tie,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('targetTable: $targetTable, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('tie: $tie')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(targetTable, syncedAt, tie);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.targetTable == this.targetTable &&
          other.syncedAt == this.syncedAt &&
          other.tie == this.tie);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> targetTable;
  final Value<String> syncedAt;
  final Value<String> tie;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.targetTable = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.tie = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String targetTable,
    required String syncedAt,
    this.tie = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : targetTable = Value(targetTable),
       syncedAt = Value(syncedAt);
  static Insertable<SyncCursor> custom({
    Expression<String>? targetTable,
    Expression<String>? syncedAt,
    Expression<String>? tie,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (targetTable != null) 'target_table': targetTable,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (tie != null) 'tie': tie,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? targetTable,
    Value<String>? syncedAt,
    Value<String>? tie,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      targetTable: targetTable ?? this.targetTable,
      syncedAt: syncedAt ?? this.syncedAt,
      tie: tie ?? this.tie,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<String>(syncedAt.value);
    }
    if (tie.present) {
      map['tie'] = Variable<String>(tie.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('targetTable: $targetTable, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('tie: $tie, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LocalSession extends Table with TableInfo<LocalSession, LocalSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LocalSession(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (id = 1)',
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _loginMeta = const VerificationMeta('login');
  late final GeneratedColumn<String> login = GeneratedColumn<String>(
    'login',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _membershipIdMeta = const VerificationMeta(
    'membershipId',
  );
  late final GeneratedColumn<String> membershipId = GeneratedColumn<String>(
    'membership_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deviceSeriesMeta = const VerificationMeta(
    'deviceSeries',
  );
  late final GeneratedColumn<String> deviceSeries = GeneratedColumn<String>(
    'device_series',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _clockOffsetMsMeta = const VerificationMeta(
    'clockOffsetMs',
  );
  late final GeneratedColumn<int> clockOffsetMs = GeneratedColumn<int>(
    'clock_offset_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  late final GeneratedColumn<String> lastSyncAt = GeneratedColumn<String>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _journalSeenAtMeta = const VerificationMeta(
    'journalSeenAt',
  );
  late final GeneratedColumn<String> journalSeenAt = GeneratedColumn<String>(
    'journal_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    login,
    membershipId,
    schoolId,
    role,
    displayName,
    deviceId,
    deviceSeries,
    clockOffsetMs,
    lastSyncAt,
    journalSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_session';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('login')) {
      context.handle(
        _loginMeta,
        login.isAcceptableOrUnknown(data['login']!, _loginMeta),
      );
    } else if (isInserting) {
      context.missing(_loginMeta);
    }
    if (data.containsKey('membership_id')) {
      context.handle(
        _membershipIdMeta,
        membershipId.isAcceptableOrUnknown(
          data['membership_id']!,
          _membershipIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_membershipIdMeta);
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_series')) {
      context.handle(
        _deviceSeriesMeta,
        deviceSeries.isAcceptableOrUnknown(
          data['device_series']!,
          _deviceSeriesMeta,
        ),
      );
    }
    if (data.containsKey('clock_offset_ms')) {
      context.handle(
        _clockOffsetMsMeta,
        clockOffsetMs.isAcceptableOrUnknown(
          data['clock_offset_ms']!,
          _clockOffsetMsMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    if (data.containsKey('journal_seen_at')) {
      context.handle(
        _journalSeenAtMeta,
        journalSeenAt.isAcceptableOrUnknown(
          data['journal_seen_at']!,
          _journalSeenAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      login: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login'],
      )!,
      membershipId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}membership_id'],
      )!,
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceSeries: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_series'],
      ),
      clockOffsetMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clock_offset_ms'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_at'],
      ),
      journalSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}journal_seen_at'],
      ),
    );
  }

  @override
  LocalSession createAlias(String alias) {
    return LocalSession(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class LocalSessionRow extends DataClass implements Insertable<LocalSessionRow> {
  final int id;
  final String userId;
  final String login;
  final String membershipId;
  final String schoolId;
  final String role;
  final String displayName;
  final String deviceId;
  final String? deviceSeries;
  final int clockOffsetMs;
  final String? lastSyncAt;
  final String? journalSeenAt;
  const LocalSessionRow({
    required this.id,
    required this.userId,
    required this.login,
    required this.membershipId,
    required this.schoolId,
    required this.role,
    required this.displayName,
    required this.deviceId,
    this.deviceSeries,
    required this.clockOffsetMs,
    this.lastSyncAt,
    this.journalSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['login'] = Variable<String>(login);
    map['membership_id'] = Variable<String>(membershipId);
    map['school_id'] = Variable<String>(schoolId);
    map['role'] = Variable<String>(role);
    map['display_name'] = Variable<String>(displayName);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || deviceSeries != null) {
      map['device_series'] = Variable<String>(deviceSeries);
    }
    map['clock_offset_ms'] = Variable<int>(clockOffsetMs);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<String>(lastSyncAt);
    }
    if (!nullToAbsent || journalSeenAt != null) {
      map['journal_seen_at'] = Variable<String>(journalSeenAt);
    }
    return map;
  }

  LocalSessionCompanion toCompanion(bool nullToAbsent) {
    return LocalSessionCompanion(
      id: Value(id),
      userId: Value(userId),
      login: Value(login),
      membershipId: Value(membershipId),
      schoolId: Value(schoolId),
      role: Value(role),
      displayName: Value(displayName),
      deviceId: Value(deviceId),
      deviceSeries: deviceSeries == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceSeries),
      clockOffsetMs: Value(clockOffsetMs),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
      journalSeenAt: journalSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(journalSeenAt),
    );
  }

  factory LocalSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSessionRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['user_id']),
      login: serializer.fromJson<String>(json['login']),
      membershipId: serializer.fromJson<String>(json['membership_id']),
      schoolId: serializer.fromJson<String>(json['school_id']),
      role: serializer.fromJson<String>(json['role']),
      displayName: serializer.fromJson<String>(json['display_name']),
      deviceId: serializer.fromJson<String>(json['device_id']),
      deviceSeries: serializer.fromJson<String?>(json['device_series']),
      clockOffsetMs: serializer.fromJson<int>(json['clock_offset_ms']),
      lastSyncAt: serializer.fromJson<String?>(json['last_sync_at']),
      journalSeenAt: serializer.fromJson<String?>(json['journal_seen_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'user_id': serializer.toJson<String>(userId),
      'login': serializer.toJson<String>(login),
      'membership_id': serializer.toJson<String>(membershipId),
      'school_id': serializer.toJson<String>(schoolId),
      'role': serializer.toJson<String>(role),
      'display_name': serializer.toJson<String>(displayName),
      'device_id': serializer.toJson<String>(deviceId),
      'device_series': serializer.toJson<String?>(deviceSeries),
      'clock_offset_ms': serializer.toJson<int>(clockOffsetMs),
      'last_sync_at': serializer.toJson<String?>(lastSyncAt),
      'journal_seen_at': serializer.toJson<String?>(journalSeenAt),
    };
  }

  LocalSessionRow copyWith({
    int? id,
    String? userId,
    String? login,
    String? membershipId,
    String? schoolId,
    String? role,
    String? displayName,
    String? deviceId,
    Value<String?> deviceSeries = const Value.absent(),
    int? clockOffsetMs,
    Value<String?> lastSyncAt = const Value.absent(),
    Value<String?> journalSeenAt = const Value.absent(),
  }) => LocalSessionRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    login: login ?? this.login,
    membershipId: membershipId ?? this.membershipId,
    schoolId: schoolId ?? this.schoolId,
    role: role ?? this.role,
    displayName: displayName ?? this.displayName,
    deviceId: deviceId ?? this.deviceId,
    deviceSeries: deviceSeries.present ? deviceSeries.value : this.deviceSeries,
    clockOffsetMs: clockOffsetMs ?? this.clockOffsetMs,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    journalSeenAt: journalSeenAt.present
        ? journalSeenAt.value
        : this.journalSeenAt,
  );
  LocalSessionRow copyWithCompanion(LocalSessionCompanion data) {
    return LocalSessionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      login: data.login.present ? data.login.value : this.login,
      membershipId: data.membershipId.present
          ? data.membershipId.value
          : this.membershipId,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      role: data.role.present ? data.role.value : this.role,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceSeries: data.deviceSeries.present
          ? data.deviceSeries.value
          : this.deviceSeries,
      clockOffsetMs: data.clockOffsetMs.present
          ? data.clockOffsetMs.value
          : this.clockOffsetMs,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
      journalSeenAt: data.journalSeenAt.present
          ? data.journalSeenAt.value
          : this.journalSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSessionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('login: $login, ')
          ..write('membershipId: $membershipId, ')
          ..write('schoolId: $schoolId, ')
          ..write('role: $role, ')
          ..write('displayName: $displayName, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceSeries: $deviceSeries, ')
          ..write('clockOffsetMs: $clockOffsetMs, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('journalSeenAt: $journalSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    login,
    membershipId,
    schoolId,
    role,
    displayName,
    deviceId,
    deviceSeries,
    clockOffsetMs,
    lastSyncAt,
    journalSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSessionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.login == this.login &&
          other.membershipId == this.membershipId &&
          other.schoolId == this.schoolId &&
          other.role == this.role &&
          other.displayName == this.displayName &&
          other.deviceId == this.deviceId &&
          other.deviceSeries == this.deviceSeries &&
          other.clockOffsetMs == this.clockOffsetMs &&
          other.lastSyncAt == this.lastSyncAt &&
          other.journalSeenAt == this.journalSeenAt);
}

class LocalSessionCompanion extends UpdateCompanion<LocalSessionRow> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> login;
  final Value<String> membershipId;
  final Value<String> schoolId;
  final Value<String> role;
  final Value<String> displayName;
  final Value<String> deviceId;
  final Value<String?> deviceSeries;
  final Value<int> clockOffsetMs;
  final Value<String?> lastSyncAt;
  final Value<String?> journalSeenAt;
  const LocalSessionCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.login = const Value.absent(),
    this.membershipId = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.role = const Value.absent(),
    this.displayName = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceSeries = const Value.absent(),
    this.clockOffsetMs = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.journalSeenAt = const Value.absent(),
  });
  LocalSessionCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String login,
    required String membershipId,
    required String schoolId,
    required String role,
    required String displayName,
    required String deviceId,
    this.deviceSeries = const Value.absent(),
    this.clockOffsetMs = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.journalSeenAt = const Value.absent(),
  }) : userId = Value(userId),
       login = Value(login),
       membershipId = Value(membershipId),
       schoolId = Value(schoolId),
       role = Value(role),
       displayName = Value(displayName),
       deviceId = Value(deviceId);
  static Insertable<LocalSessionRow> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? login,
    Expression<String>? membershipId,
    Expression<String>? schoolId,
    Expression<String>? role,
    Expression<String>? displayName,
    Expression<String>? deviceId,
    Expression<String>? deviceSeries,
    Expression<int>? clockOffsetMs,
    Expression<String>? lastSyncAt,
    Expression<String>? journalSeenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (login != null) 'login': login,
      if (membershipId != null) 'membership_id': membershipId,
      if (schoolId != null) 'school_id': schoolId,
      if (role != null) 'role': role,
      if (displayName != null) 'display_name': displayName,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceSeries != null) 'device_series': deviceSeries,
      if (clockOffsetMs != null) 'clock_offset_ms': clockOffsetMs,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (journalSeenAt != null) 'journal_seen_at': journalSeenAt,
    });
  }

  LocalSessionCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? login,
    Value<String>? membershipId,
    Value<String>? schoolId,
    Value<String>? role,
    Value<String>? displayName,
    Value<String>? deviceId,
    Value<String?>? deviceSeries,
    Value<int>? clockOffsetMs,
    Value<String?>? lastSyncAt,
    Value<String?>? journalSeenAt,
  }) {
    return LocalSessionCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      login: login ?? this.login,
      membershipId: membershipId ?? this.membershipId,
      schoolId: schoolId ?? this.schoolId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      deviceId: deviceId ?? this.deviceId,
      deviceSeries: deviceSeries ?? this.deviceSeries,
      clockOffsetMs: clockOffsetMs ?? this.clockOffsetMs,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      journalSeenAt: journalSeenAt ?? this.journalSeenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (login.present) {
      map['login'] = Variable<String>(login.value);
    }
    if (membershipId.present) {
      map['membership_id'] = Variable<String>(membershipId.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceSeries.present) {
      map['device_series'] = Variable<String>(deviceSeries.value);
    }
    if (clockOffsetMs.present) {
      map['clock_offset_ms'] = Variable<int>(clockOffsetMs.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<String>(lastSyncAt.value);
    }
    if (journalSeenAt.present) {
      map['journal_seen_at'] = Variable<String>(journalSeenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSessionCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('login: $login, ')
          ..write('membershipId: $membershipId, ')
          ..write('schoolId: $schoolId, ')
          ..write('role: $role, ')
          ..write('displayName: $displayName, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceSeries: $deviceSeries, ')
          ..write('clockOffsetMs: $clockOffsetMs, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('journalSeenAt: $journalSeenAt')
          ..write(')'))
        .toString();
  }
}

class Drafts extends Table with TableInfo<Drafts, DraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Drafts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [key, payload, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Drafts createAlias(String alias) {
    return Drafts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class DraftRow extends DataClass implements Insertable<DraftRow> {
  final String key;
  final String payload;
  final String updatedAt;
  const DraftRow({
    required this.key,
    required this.payload,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  DraftsCompanion toCompanion(bool nullToAbsent) {
    return DraftsCompanion(
      key: Value(key),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
    );
  }

  factory DraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftRow(
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<String>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
      'updated_at': serializer.toJson<String>(updatedAt),
    };
  }

  DraftRow copyWith({String? key, String? payload, String? updatedAt}) =>
      DraftRow(
        key: key ?? this.key,
        payload: payload ?? this.payload,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DraftRow copyWithCompanion(DraftsCompanion data) {
    return DraftRow(
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftRow(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payload, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftRow &&
          other.key == this.key &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt);
}

class DraftsCompanion extends UpdateCompanion<DraftRow> {
  final Value<String> key;
  final Value<String> payload;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const DraftsCompanion({
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftsCompanion.insert({
    required String key,
    required String payload,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payload = Value(payload),
       updatedAt = Value(updatedAt);
  static Insertable<DraftRow> custom({
    Expression<String>? key,
    Expression<String>? payload,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftsCompanion copyWith({
    Value<String>? key,
    Value<String>? payload,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return DraftsCompanion(
      key: key ?? this.key,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftsCompanion(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class FileUploads extends Table with TableInfo<FileUploads, FileUploadRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FileUploads(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _objectPathMeta = const VerificationMeta(
    'objectPath',
  );
  late final GeneratedColumn<String> objectPath = GeneratedColumn<String>(
    'object_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localPath,
    bucket,
    objectPath,
    contentType,
    attempts,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_uploads';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileUploadRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    } else if (isInserting) {
      context.missing(_bucketMeta);
    }
    if (data.containsKey('object_path')) {
      context.handle(
        _objectPathMeta,
        objectPath.isAcceptableOrUnknown(data['object_path']!, _objectPathMeta),
      );
    } else if (isInserting) {
      context.missing(_objectPathMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FileUploadRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileUploadRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      )!,
      objectPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_path'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  FileUploads createAlias(String alias) {
    return FileUploads(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class FileUploadRow extends DataClass implements Insertable<FileUploadRow> {
  final int id;
  final String localPath;
  final String bucket;
  final String objectPath;
  final String contentType;
  final int attempts;
  final String createdAt;
  const FileUploadRow({
    required this.id,
    required this.localPath,
    required this.bucket,
    required this.objectPath,
    required this.contentType,
    required this.attempts,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['local_path'] = Variable<String>(localPath);
    map['bucket'] = Variable<String>(bucket);
    map['object_path'] = Variable<String>(objectPath);
    map['content_type'] = Variable<String>(contentType);
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  FileUploadsCompanion toCompanion(bool nullToAbsent) {
    return FileUploadsCompanion(
      id: Value(id),
      localPath: Value(localPath),
      bucket: Value(bucket),
      objectPath: Value(objectPath),
      contentType: Value(contentType),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
    );
  }

  factory FileUploadRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileUploadRow(
      id: serializer.fromJson<int>(json['id']),
      localPath: serializer.fromJson<String>(json['local_path']),
      bucket: serializer.fromJson<String>(json['bucket']),
      objectPath: serializer.fromJson<String>(json['object_path']),
      contentType: serializer.fromJson<String>(json['content_type']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<String>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'local_path': serializer.toJson<String>(localPath),
      'bucket': serializer.toJson<String>(bucket),
      'object_path': serializer.toJson<String>(objectPath),
      'content_type': serializer.toJson<String>(contentType),
      'attempts': serializer.toJson<int>(attempts),
      'created_at': serializer.toJson<String>(createdAt),
    };
  }

  FileUploadRow copyWith({
    int? id,
    String? localPath,
    String? bucket,
    String? objectPath,
    String? contentType,
    int? attempts,
    String? createdAt,
  }) => FileUploadRow(
    id: id ?? this.id,
    localPath: localPath ?? this.localPath,
    bucket: bucket ?? this.bucket,
    objectPath: objectPath ?? this.objectPath,
    contentType: contentType ?? this.contentType,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
  );
  FileUploadRow copyWithCompanion(FileUploadsCompanion data) {
    return FileUploadRow(
      id: data.id.present ? data.id.value : this.id,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      objectPath: data.objectPath.present
          ? data.objectPath.value
          : this.objectPath,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileUploadRow(')
          ..write('id: $id, ')
          ..write('localPath: $localPath, ')
          ..write('bucket: $bucket, ')
          ..write('objectPath: $objectPath, ')
          ..write('contentType: $contentType, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localPath,
    bucket,
    objectPath,
    contentType,
    attempts,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileUploadRow &&
          other.id == this.id &&
          other.localPath == this.localPath &&
          other.bucket == this.bucket &&
          other.objectPath == this.objectPath &&
          other.contentType == this.contentType &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt);
}

class FileUploadsCompanion extends UpdateCompanion<FileUploadRow> {
  final Value<int> id;
  final Value<String> localPath;
  final Value<String> bucket;
  final Value<String> objectPath;
  final Value<String> contentType;
  final Value<int> attempts;
  final Value<String> createdAt;
  const FileUploadsCompanion({
    this.id = const Value.absent(),
    this.localPath = const Value.absent(),
    this.bucket = const Value.absent(),
    this.objectPath = const Value.absent(),
    this.contentType = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FileUploadsCompanion.insert({
    this.id = const Value.absent(),
    required String localPath,
    required String bucket,
    required String objectPath,
    required String contentType,
    this.attempts = const Value.absent(),
    required String createdAt,
  }) : localPath = Value(localPath),
       bucket = Value(bucket),
       objectPath = Value(objectPath),
       contentType = Value(contentType),
       createdAt = Value(createdAt);
  static Insertable<FileUploadRow> custom({
    Expression<int>? id,
    Expression<String>? localPath,
    Expression<String>? bucket,
    Expression<String>? objectPath,
    Expression<String>? contentType,
    Expression<int>? attempts,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localPath != null) 'local_path': localPath,
      if (bucket != null) 'bucket': bucket,
      if (objectPath != null) 'object_path': objectPath,
      if (contentType != null) 'content_type': contentType,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FileUploadsCompanion copyWith({
    Value<int>? id,
    Value<String>? localPath,
    Value<String>? bucket,
    Value<String>? objectPath,
    Value<String>? contentType,
    Value<int>? attempts,
    Value<String>? createdAt,
  }) {
    return FileUploadsCompanion(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      bucket: bucket ?? this.bucket,
      objectPath: objectPath ?? this.objectPath,
      contentType: contentType ?? this.contentType,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (objectPath.present) {
      map['object_path'] = Variable<String>(objectPath.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileUploadsCompanion(')
          ..write('id: $id, ')
          ..write('localPath: $localPath, ')
          ..write('bucket: $bucket, ')
          ..write('objectPath: $objectPath, ')
          ..write('contentType: $contentType, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class DeviceIdentity extends Table
    with TableInfo<DeviceIdentity, DeviceIdentityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DeviceIdentity(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (id = 1)',
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _noticeMeta = const VerificationMeta('notice');
  late final GeneratedColumn<String> notice = GeneratedColumn<String>(
    'notice',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [id, deviceId, notice];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_identity';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceIdentityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('notice')) {
      context.handle(
        _noticeMeta,
        notice.isAcceptableOrUnknown(data['notice']!, _noticeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceIdentityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceIdentityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      notice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notice'],
      ),
    );
  }

  @override
  DeviceIdentity createAlias(String alias) {
    return DeviceIdentity(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class DeviceIdentityRow extends DataClass
    implements Insertable<DeviceIdentityRow> {
  final int id;
  final String deviceId;

  /// Message à montrer à l'ouverture (ex. téléphone déconnecté par le directeur).
  final String? notice;
  const DeviceIdentityRow({
    required this.id,
    required this.deviceId,
    this.notice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || notice != null) {
      map['notice'] = Variable<String>(notice);
    }
    return map;
  }

  DeviceIdentityCompanion toCompanion(bool nullToAbsent) {
    return DeviceIdentityCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      notice: notice == null && nullToAbsent
          ? const Value.absent()
          : Value(notice),
    );
  }

  factory DeviceIdentityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceIdentityRow(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['device_id']),
      notice: serializer.fromJson<String?>(json['notice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'device_id': serializer.toJson<String>(deviceId),
      'notice': serializer.toJson<String?>(notice),
    };
  }

  DeviceIdentityRow copyWith({
    int? id,
    String? deviceId,
    Value<String?> notice = const Value.absent(),
  }) => DeviceIdentityRow(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    notice: notice.present ? notice.value : this.notice,
  );
  DeviceIdentityRow copyWithCompanion(DeviceIdentityCompanion data) {
    return DeviceIdentityRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      notice: data.notice.present ? data.notice.value : this.notice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIdentityRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('notice: $notice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId, notice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceIdentityRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.notice == this.notice);
}

class DeviceIdentityCompanion extends UpdateCompanion<DeviceIdentityRow> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<String?> notice;
  const DeviceIdentityCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.notice = const Value.absent(),
  });
  DeviceIdentityCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    this.notice = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<DeviceIdentityRow> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<String>? notice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (notice != null) 'notice': notice,
    });
  }

  DeviceIdentityCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<String?>? notice,
  }) {
    return DeviceIdentityCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      notice: notice ?? this.notice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (notice.present) {
      map['notice'] = Variable<String>(notice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIdentityCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('notice: $notice')
          ..write(')'))
        .toString();
  }
}

class AppLock extends Table with TableInfo<AppLock, AppLockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AppLock(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY CHECK (id = 1)',
  );
  static const VerificationMeta _pinHashMeta = const VerificationMeta(
    'pinHash',
  );
  late final GeneratedColumn<String> pinHash = GeneratedColumn<String>(
    'pin_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pinSaltMeta = const VerificationMeta(
    'pinSalt',
  );
  late final GeneratedColumn<String> pinSalt = GeneratedColumn<String>(
    'pin_salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _iterationsMeta = const VerificationMeta(
    'iterations',
  );
  late final GeneratedColumn<int> iterations = GeneratedColumn<int>(
    'iterations',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _biometricMeta = const VerificationMeta(
    'biometric',
  );
  late final GeneratedColumn<bool> biometric = GeneratedColumn<bool>(
    'biometric',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT FALSE',
    defaultValue: const CustomExpression('FALSE'),
  );
  static const VerificationMeta _failedAttemptsMeta = const VerificationMeta(
    'failedAttempts',
  );
  late final GeneratedColumn<int> failedAttempts = GeneratedColumn<int>(
    'failed_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _blockedUntilMeta = const VerificationMeta(
    'blockedUntil',
  );
  late final GeneratedColumn<String> blockedUntil = GeneratedColumn<String>(
    'blocked_until',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pinHash,
    pinSalt,
    iterations,
    biometric,
    failedAttempts,
    blockedUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_lock';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppLockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pin_hash')) {
      context.handle(
        _pinHashMeta,
        pinHash.isAcceptableOrUnknown(data['pin_hash']!, _pinHashMeta),
      );
    } else if (isInserting) {
      context.missing(_pinHashMeta);
    }
    if (data.containsKey('pin_salt')) {
      context.handle(
        _pinSaltMeta,
        pinSalt.isAcceptableOrUnknown(data['pin_salt']!, _pinSaltMeta),
      );
    } else if (isInserting) {
      context.missing(_pinSaltMeta);
    }
    if (data.containsKey('iterations')) {
      context.handle(
        _iterationsMeta,
        iterations.isAcceptableOrUnknown(data['iterations']!, _iterationsMeta),
      );
    } else if (isInserting) {
      context.missing(_iterationsMeta);
    }
    if (data.containsKey('biometric')) {
      context.handle(
        _biometricMeta,
        biometric.isAcceptableOrUnknown(data['biometric']!, _biometricMeta),
      );
    }
    if (data.containsKey('failed_attempts')) {
      context.handle(
        _failedAttemptsMeta,
        failedAttempts.isAcceptableOrUnknown(
          data['failed_attempts']!,
          _failedAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('blocked_until')) {
      context.handle(
        _blockedUntilMeta,
        blockedUntil.isAcceptableOrUnknown(
          data['blocked_until']!,
          _blockedUntilMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppLockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppLockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pinHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_hash'],
      )!,
      pinSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pin_salt'],
      )!,
      iterations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iterations'],
      )!,
      biometric: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}biometric'],
      )!,
      failedAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_attempts'],
      )!,
      blockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blocked_until'],
      ),
    );
  }

  @override
  AppLock createAlias(String alias) {
    return AppLock(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AppLockRow extends DataClass implements Insertable<AppLockRow> {
  final int id;
  final String pinHash;
  final String pinSalt;
  final int iterations;
  final bool biometric;
  final int failedAttempts;
  final String? blockedUntil;
  const AppLockRow({
    required this.id,
    required this.pinHash,
    required this.pinSalt,
    required this.iterations,
    required this.biometric,
    required this.failedAttempts,
    this.blockedUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pin_hash'] = Variable<String>(pinHash);
    map['pin_salt'] = Variable<String>(pinSalt);
    map['iterations'] = Variable<int>(iterations);
    map['biometric'] = Variable<bool>(biometric);
    map['failed_attempts'] = Variable<int>(failedAttempts);
    if (!nullToAbsent || blockedUntil != null) {
      map['blocked_until'] = Variable<String>(blockedUntil);
    }
    return map;
  }

  AppLockCompanion toCompanion(bool nullToAbsent) {
    return AppLockCompanion(
      id: Value(id),
      pinHash: Value(pinHash),
      pinSalt: Value(pinSalt),
      iterations: Value(iterations),
      biometric: Value(biometric),
      failedAttempts: Value(failedAttempts),
      blockedUntil: blockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(blockedUntil),
    );
  }

  factory AppLockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppLockRow(
      id: serializer.fromJson<int>(json['id']),
      pinHash: serializer.fromJson<String>(json['pin_hash']),
      pinSalt: serializer.fromJson<String>(json['pin_salt']),
      iterations: serializer.fromJson<int>(json['iterations']),
      biometric: serializer.fromJson<bool>(json['biometric']),
      failedAttempts: serializer.fromJson<int>(json['failed_attempts']),
      blockedUntil: serializer.fromJson<String?>(json['blocked_until']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pin_hash': serializer.toJson<String>(pinHash),
      'pin_salt': serializer.toJson<String>(pinSalt),
      'iterations': serializer.toJson<int>(iterations),
      'biometric': serializer.toJson<bool>(biometric),
      'failed_attempts': serializer.toJson<int>(failedAttempts),
      'blocked_until': serializer.toJson<String?>(blockedUntil),
    };
  }

  AppLockRow copyWith({
    int? id,
    String? pinHash,
    String? pinSalt,
    int? iterations,
    bool? biometric,
    int? failedAttempts,
    Value<String?> blockedUntil = const Value.absent(),
  }) => AppLockRow(
    id: id ?? this.id,
    pinHash: pinHash ?? this.pinHash,
    pinSalt: pinSalt ?? this.pinSalt,
    iterations: iterations ?? this.iterations,
    biometric: biometric ?? this.biometric,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    blockedUntil: blockedUntil.present ? blockedUntil.value : this.blockedUntil,
  );
  AppLockRow copyWithCompanion(AppLockCompanion data) {
    return AppLockRow(
      id: data.id.present ? data.id.value : this.id,
      pinHash: data.pinHash.present ? data.pinHash.value : this.pinHash,
      pinSalt: data.pinSalt.present ? data.pinSalt.value : this.pinSalt,
      iterations: data.iterations.present
          ? data.iterations.value
          : this.iterations,
      biometric: data.biometric.present ? data.biometric.value : this.biometric,
      failedAttempts: data.failedAttempts.present
          ? data.failedAttempts.value
          : this.failedAttempts,
      blockedUntil: data.blockedUntil.present
          ? data.blockedUntil.value
          : this.blockedUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppLockRow(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('iterations: $iterations, ')
          ..write('biometric: $biometric, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('blockedUntil: $blockedUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pinHash,
    pinSalt,
    iterations,
    biometric,
    failedAttempts,
    blockedUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLockRow &&
          other.id == this.id &&
          other.pinHash == this.pinHash &&
          other.pinSalt == this.pinSalt &&
          other.iterations == this.iterations &&
          other.biometric == this.biometric &&
          other.failedAttempts == this.failedAttempts &&
          other.blockedUntil == this.blockedUntil);
}

class AppLockCompanion extends UpdateCompanion<AppLockRow> {
  final Value<int> id;
  final Value<String> pinHash;
  final Value<String> pinSalt;
  final Value<int> iterations;
  final Value<bool> biometric;
  final Value<int> failedAttempts;
  final Value<String?> blockedUntil;
  const AppLockCompanion({
    this.id = const Value.absent(),
    this.pinHash = const Value.absent(),
    this.pinSalt = const Value.absent(),
    this.iterations = const Value.absent(),
    this.biometric = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.blockedUntil = const Value.absent(),
  });
  AppLockCompanion.insert({
    this.id = const Value.absent(),
    required String pinHash,
    required String pinSalt,
    required int iterations,
    this.biometric = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.blockedUntil = const Value.absent(),
  }) : pinHash = Value(pinHash),
       pinSalt = Value(pinSalt),
       iterations = Value(iterations);
  static Insertable<AppLockRow> custom({
    Expression<int>? id,
    Expression<String>? pinHash,
    Expression<String>? pinSalt,
    Expression<int>? iterations,
    Expression<bool>? biometric,
    Expression<int>? failedAttempts,
    Expression<String>? blockedUntil,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pinHash != null) 'pin_hash': pinHash,
      if (pinSalt != null) 'pin_salt': pinSalt,
      if (iterations != null) 'iterations': iterations,
      if (biometric != null) 'biometric': biometric,
      if (failedAttempts != null) 'failed_attempts': failedAttempts,
      if (blockedUntil != null) 'blocked_until': blockedUntil,
    });
  }

  AppLockCompanion copyWith({
    Value<int>? id,
    Value<String>? pinHash,
    Value<String>? pinSalt,
    Value<int>? iterations,
    Value<bool>? biometric,
    Value<int>? failedAttempts,
    Value<String?>? blockedUntil,
  }) {
    return AppLockCompanion(
      id: id ?? this.id,
      pinHash: pinHash ?? this.pinHash,
      pinSalt: pinSalt ?? this.pinSalt,
      iterations: iterations ?? this.iterations,
      biometric: biometric ?? this.biometric,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      blockedUntil: blockedUntil ?? this.blockedUntil,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pinHash.present) {
      map['pin_hash'] = Variable<String>(pinHash.value);
    }
    if (pinSalt.present) {
      map['pin_salt'] = Variable<String>(pinSalt.value);
    }
    if (iterations.present) {
      map['iterations'] = Variable<int>(iterations.value);
    }
    if (biometric.present) {
      map['biometric'] = Variable<bool>(biometric.value);
    }
    if (failedAttempts.present) {
      map['failed_attempts'] = Variable<int>(failedAttempts.value);
    }
    if (blockedUntil.present) {
      map['blocked_until'] = Variable<String>(blockedUntil.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppLockCompanion(')
          ..write('id: $id, ')
          ..write('pinHash: $pinHash, ')
          ..write('pinSalt: $pinSalt, ')
          ..write('iterations: $iterations, ')
          ..write('biometric: $biometric, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('blockedUntil: $blockedUntil')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Schools schools = Schools(this);
  late final SchoolYears schoolYears = SchoolYears(this);
  late final AdminHeaders adminHeaders = AdminHeaders(this);
  late final ModulesCatalog modulesCatalog = ModulesCatalog(this);
  late final SchoolModules schoolModules = SchoolModules(this);
  late final Memberships memberships = Memberships(this);
  late final DelegatePermissions delegatePermissions = DelegatePermissions(
    this,
  );
  late final Devices devices = Devices(this);
  late final AuditLog auditLog = AuditLog(this);
  late final Levels levels = Levels(this);
  late final Teachers teachers = Teachers(this);
  late final TeacherPostings teacherPostings = TeacherPostings(this);
  late final TeacherInterruptions teacherInterruptions = TeacherInterruptions(
    this,
  );
  late final TeacherAwards teacherAwards = TeacherAwards(this);
  late final TeacherDiplomas teacherDiplomas = TeacherDiplomas(this);
  late final Classes classes = Classes(this);
  late final TeacherYearAssignments teacherYearAssignments =
      TeacherYearAssignments(this);
  late final Students students = Students(this);
  late final StudentRegistry studentRegistry = StudentRegistry(this);
  late final Guardians guardians = Guardians(this);
  late final Enrollments enrollments = Enrollments(this);
  late final Index enrollmentsClass = Index(
    'enrollments_class',
    'CREATE INDEX enrollments_class ON enrollments (class_id)',
  );
  late final Index enrollmentsStudent = Index(
    'enrollments_student',
    'CREATE INDEX enrollments_student ON enrollments (student_id)',
  );
  late final Outbox outbox = Outbox(this);
  late final SyncCursors syncCursors = SyncCursors(this);
  late final LocalSession localSession = LocalSession(this);
  late final Drafts drafts = Drafts(this);
  late final FileUploads fileUploads = FileUploads(this);
  late final DeviceIdentity deviceIdentity = DeviceIdentity(this);
  late final AppLock appLock = AppLock(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schools,
    schoolYears,
    adminHeaders,
    modulesCatalog,
    schoolModules,
    memberships,
    delegatePermissions,
    devices,
    auditLog,
    levels,
    teachers,
    teacherPostings,
    teacherInterruptions,
    teacherAwards,
    teacherDiplomas,
    classes,
    teacherYearAssignments,
    students,
    studentRegistry,
    guardians,
    enrollments,
    enrollmentsClass,
    enrollmentsStudent,
    outbox,
    syncCursors,
    localSession,
    drafts,
    fileUploads,
    deviceIdentity,
    appLock,
  ];
}

typedef $SchoolsCreateCompanionBuilder = SchoolsCompanion Function({
  required String id,
  required String name,
  Value<String?> commune,
  Value<String?> departement,
  Value<String?> province,
  Value<String?> region,
  Value<String> schoolType,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String?> directorName,
  Value<bool> managesPrimary,
  Value<double> gradingScale,
  Value<bool> showRaceReligion,
  Value<String> absentRule,
  Value<String?> currentSchoolYearId,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $SchoolsUpdateCompanionBuilder = SchoolsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> commune,
  Value<String?> departement,
  Value<String?> province,
  Value<String?> region,
  Value<String> schoolType,
  Value<String?> phone,
  Value<String?> email,
  Value<String?> address,
  Value<String?> directorName,
  Value<bool> managesPrimary,
  Value<double> gradingScale,
  Value<bool> showRaceReligion,
  Value<String> absentRule,
  Value<String?> currentSchoolYearId,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $SchoolsFilterComposer extends Composer<_$AppDatabase, Schools> {
  $SchoolsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departement => $composableBuilder(
    column: $table.departement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolType => $composableBuilder(
    column: $table.schoolType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directorName => $composableBuilder(
    column: $table.directorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get managesPrimary => $composableBuilder(
    column: $table.managesPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gradingScale => $composableBuilder(
    column: $table.gradingScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get showRaceReligion => $composableBuilder(
    column: $table.showRaceReligion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get absentRule => $composableBuilder(
    column: $table.absentRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentSchoolYearId => $composableBuilder(
    column: $table.currentSchoolYearId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $SchoolsOrderingComposer extends Composer<_$AppDatabase, Schools> {
  $SchoolsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departement => $composableBuilder(
    column: $table.departement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolType => $composableBuilder(
    column: $table.schoolType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directorName => $composableBuilder(
    column: $table.directorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get managesPrimary => $composableBuilder(
    column: $table.managesPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gradingScale => $composableBuilder(
    column: $table.gradingScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get showRaceReligion => $composableBuilder(
    column: $table.showRaceReligion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get absentRule => $composableBuilder(
    column: $table.absentRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentSchoolYearId => $composableBuilder(
    column: $table.currentSchoolYearId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SchoolsAnnotationComposer extends Composer<_$AppDatabase, Schools> {
  $SchoolsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get commune =>
      $composableBuilder(column: $table.commune, builder: (column) => column);

  GeneratedColumn<String> get departement => $composableBuilder(
    column: $table.departement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get schoolType => $composableBuilder(
    column: $table.schoolType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get directorName => $composableBuilder(
    column: $table.directorName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get managesPrimary => $composableBuilder(
    column: $table.managesPrimary,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gradingScale => $composableBuilder(
    column: $table.gradingScale,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get showRaceReligion => $composableBuilder(
    column: $table.showRaceReligion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get absentRule => $composableBuilder(
    column: $table.absentRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentSchoolYearId => $composableBuilder(
    column: $table.currentSchoolYearId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $SchoolsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Schools,
          SchoolRow,
          $SchoolsFilterComposer,
          $SchoolsOrderingComposer,
          $SchoolsAnnotationComposer,
          $SchoolsCreateCompanionBuilder,
          $SchoolsUpdateCompanionBuilder,
          (SchoolRow, BaseReferences<_$AppDatabase, Schools, SchoolRow>),
          SchoolRow,
          PrefetchHooks Function()
        > {
  $SchoolsTableManager(_$AppDatabase db, Schools table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SchoolsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SchoolsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SchoolsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> commune = const Value.absent(),
                Value<String?> departement = const Value.absent(),
                Value<String?> province = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String> schoolType = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> directorName = const Value.absent(),
                Value<bool> managesPrimary = const Value.absent(),
                Value<double> gradingScale = const Value.absent(),
                Value<bool> showRaceReligion = const Value.absent(),
                Value<String> absentRule = const Value.absent(),
                Value<String?> currentSchoolYearId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolsCompanion(
                id: id,
                name: name,
                commune: commune,
                departement: departement,
                province: province,
                region: region,
                schoolType: schoolType,
                phone: phone,
                email: email,
                address: address,
                directorName: directorName,
                managesPrimary: managesPrimary,
                gradingScale: gradingScale,
                showRaceReligion: showRaceReligion,
                absentRule: absentRule,
                currentSchoolYearId: currentSchoolYearId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> commune = const Value.absent(),
                Value<String?> departement = const Value.absent(),
                Value<String?> province = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String> schoolType = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> directorName = const Value.absent(),
                Value<bool> managesPrimary = const Value.absent(),
                Value<double> gradingScale = const Value.absent(),
                Value<bool> showRaceReligion = const Value.absent(),
                Value<String> absentRule = const Value.absent(),
                Value<String?> currentSchoolYearId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolsCompanion.insert(
                id: id,
                name: name,
                commune: commune,
                departement: departement,
                province: province,
                region: region,
                schoolType: schoolType,
                phone: phone,
                email: email,
                address: address,
                directorName: directorName,
                managesPrimary: managesPrimary,
                gradingScale: gradingScale,
                showRaceReligion: showRaceReligion,
                absentRule: absentRule,
                currentSchoolYearId: currentSchoolYearId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Schools, SchoolRow>(table),
                  BaseReferences<_$AppDatabase, Schools, SchoolRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SchoolsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Schools,
      SchoolRow,
      $SchoolsFilterComposer,
      $SchoolsOrderingComposer,
      $SchoolsAnnotationComposer,
      $SchoolsCreateCompanionBuilder,
      $SchoolsUpdateCompanionBuilder,
      (SchoolRow, BaseReferences<_$AppDatabase, Schools, SchoolRow>),
      SchoolRow,
      PrefetchHooks Function()
    >;
typedef $SchoolYearsCreateCompanionBuilder = SchoolYearsCompanion Function({
  required String id,
  required String schoolId,
  required String label,
  Value<String?> startsOn,
  Value<String?> endsOn,
  Value<String?> archivedAt,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $SchoolYearsUpdateCompanionBuilder = SchoolYearsCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> label,
  Value<String?> startsOn,
  Value<String?> endsOn,
  Value<String?> archivedAt,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $SchoolYearsFilterComposer extends Composer<_$AppDatabase, SchoolYears> {
  $SchoolYearsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $SchoolYearsOrderingComposer
    extends Composer<_$AppDatabase, SchoolYears> {
  $SchoolYearsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SchoolYearsAnnotationComposer
    extends Composer<_$AppDatabase, SchoolYears> {
  $SchoolYearsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<String> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $SchoolYearsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SchoolYears,
          SchoolYearRow,
          $SchoolYearsFilterComposer,
          $SchoolYearsOrderingComposer,
          $SchoolYearsAnnotationComposer,
          $SchoolYearsCreateCompanionBuilder,
          $SchoolYearsUpdateCompanionBuilder,
          (
            SchoolYearRow,
            BaseReferences<_$AppDatabase, SchoolYears, SchoolYearRow>,
          ),
          SchoolYearRow,
          PrefetchHooks Function()
        > {
  $SchoolYearsTableManager(_$AppDatabase db, SchoolYears table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SchoolYearsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SchoolYearsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SchoolYearsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> startsOn = const Value.absent(),
                Value<String?> endsOn = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolYearsCompanion(
                id: id,
                schoolId: schoolId,
                label: label,
                startsOn: startsOn,
                endsOn: endsOn,
                archivedAt: archivedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String label,
                Value<String?> startsOn = const Value.absent(),
                Value<String?> endsOn = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolYearsCompanion.insert(
                id: id,
                schoolId: schoolId,
                label: label,
                startsOn: startsOn,
                endsOn: endsOn,
                archivedAt: archivedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SchoolYears, SchoolYearRow>(table),
                  BaseReferences<_$AppDatabase, SchoolYears, SchoolYearRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SchoolYearsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SchoolYears,
      SchoolYearRow,
      $SchoolYearsFilterComposer,
      $SchoolYearsOrderingComposer,
      $SchoolYearsAnnotationComposer,
      $SchoolYearsCreateCompanionBuilder,
      $SchoolYearsUpdateCompanionBuilder,
      (
        SchoolYearRow,
        BaseReferences<_$AppDatabase, SchoolYears, SchoolYearRow>,
      ),
      SchoolYearRow,
      PrefetchHooks Function()
    >;
typedef $AdminHeadersCreateCompanionBuilder = AdminHeadersCompanion Function({
  required String id,
  required String schoolId,
  required String schoolYearId,
  Value<String> country,
  Value<String?> motto,
  Value<String?> ministry,
  Value<String?> region,
  Value<String?> regionalDirection,
  Value<String?> provincialDirection,
  Value<String?> ceb,
  Value<String?> province,
  Value<String?> departement,
  Value<String?> commune,
  Value<String?> schoolLabel,
  Value<String?> emblemPath,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $AdminHeadersUpdateCompanionBuilder = AdminHeadersCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> schoolYearId,
  Value<String> country,
  Value<String?> motto,
  Value<String?> ministry,
  Value<String?> region,
  Value<String?> regionalDirection,
  Value<String?> provincialDirection,
  Value<String?> ceb,
  Value<String?> province,
  Value<String?> departement,
  Value<String?> commune,
  Value<String?> schoolLabel,
  Value<String?> emblemPath,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $AdminHeadersFilterComposer
    extends Composer<_$AppDatabase, AdminHeaders> {
  $AdminHeadersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motto => $composableBuilder(
    column: $table.motto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ministry => $composableBuilder(
    column: $table.ministry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionalDirection => $composableBuilder(
    column: $table.regionalDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provincialDirection => $composableBuilder(
    column: $table.provincialDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ceb => $composableBuilder(
    column: $table.ceb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departement => $composableBuilder(
    column: $table.departement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolLabel => $composableBuilder(
    column: $table.schoolLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emblemPath => $composableBuilder(
    column: $table.emblemPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $AdminHeadersOrderingComposer
    extends Composer<_$AppDatabase, AdminHeaders> {
  $AdminHeadersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motto => $composableBuilder(
    column: $table.motto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ministry => $composableBuilder(
    column: $table.ministry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionalDirection => $composableBuilder(
    column: $table.regionalDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provincialDirection => $composableBuilder(
    column: $table.provincialDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ceb => $composableBuilder(
    column: $table.ceb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get province => $composableBuilder(
    column: $table.province,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departement => $composableBuilder(
    column: $table.departement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolLabel => $composableBuilder(
    column: $table.schoolLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emblemPath => $composableBuilder(
    column: $table.emblemPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AdminHeadersAnnotationComposer
    extends Composer<_$AppDatabase, AdminHeaders> {
  $AdminHeadersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get motto =>
      $composableBuilder(column: $table.motto, builder: (column) => column);

  GeneratedColumn<String> get ministry =>
      $composableBuilder(column: $table.ministry, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get regionalDirection => $composableBuilder(
    column: $table.regionalDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provincialDirection => $composableBuilder(
    column: $table.provincialDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ceb =>
      $composableBuilder(column: $table.ceb, builder: (column) => column);

  GeneratedColumn<String> get province =>
      $composableBuilder(column: $table.province, builder: (column) => column);

  GeneratedColumn<String> get departement => $composableBuilder(
    column: $table.departement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commune =>
      $composableBuilder(column: $table.commune, builder: (column) => column);

  GeneratedColumn<String> get schoolLabel => $composableBuilder(
    column: $table.schoolLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emblemPath => $composableBuilder(
    column: $table.emblemPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $AdminHeadersTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          AdminHeaders,
          AdminHeaderRow,
          $AdminHeadersFilterComposer,
          $AdminHeadersOrderingComposer,
          $AdminHeadersAnnotationComposer,
          $AdminHeadersCreateCompanionBuilder,
          $AdminHeadersUpdateCompanionBuilder,
          (
            AdminHeaderRow,
            BaseReferences<_$AppDatabase, AdminHeaders, AdminHeaderRow>,
          ),
          AdminHeaderRow,
          PrefetchHooks Function()
        > {
  $AdminHeadersTableManager(_$AppDatabase db, AdminHeaders table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AdminHeadersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AdminHeadersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AdminHeadersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> schoolYearId = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String?> motto = const Value.absent(),
                Value<String?> ministry = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> regionalDirection = const Value.absent(),
                Value<String?> provincialDirection = const Value.absent(),
                Value<String?> ceb = const Value.absent(),
                Value<String?> province = const Value.absent(),
                Value<String?> departement = const Value.absent(),
                Value<String?> commune = const Value.absent(),
                Value<String?> schoolLabel = const Value.absent(),
                Value<String?> emblemPath = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdminHeadersCompanion(
                id: id,
                schoolId: schoolId,
                schoolYearId: schoolYearId,
                country: country,
                motto: motto,
                ministry: ministry,
                region: region,
                regionalDirection: regionalDirection,
                provincialDirection: provincialDirection,
                ceb: ceb,
                province: province,
                departement: departement,
                commune: commune,
                schoolLabel: schoolLabel,
                emblemPath: emblemPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String schoolYearId,
                Value<String> country = const Value.absent(),
                Value<String?> motto = const Value.absent(),
                Value<String?> ministry = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> regionalDirection = const Value.absent(),
                Value<String?> provincialDirection = const Value.absent(),
                Value<String?> ceb = const Value.absent(),
                Value<String?> province = const Value.absent(),
                Value<String?> departement = const Value.absent(),
                Value<String?> commune = const Value.absent(),
                Value<String?> schoolLabel = const Value.absent(),
                Value<String?> emblemPath = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdminHeadersCompanion.insert(
                id: id,
                schoolId: schoolId,
                schoolYearId: schoolYearId,
                country: country,
                motto: motto,
                ministry: ministry,
                region: region,
                regionalDirection: regionalDirection,
                provincialDirection: provincialDirection,
                ceb: ceb,
                province: province,
                departement: departement,
                commune: commune,
                schoolLabel: schoolLabel,
                emblemPath: emblemPath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AdminHeaders, AdminHeaderRow>(table),
                  BaseReferences<_$AppDatabase, AdminHeaders, AdminHeaderRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AdminHeadersProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      AdminHeaders,
      AdminHeaderRow,
      $AdminHeadersFilterComposer,
      $AdminHeadersOrderingComposer,
      $AdminHeadersAnnotationComposer,
      $AdminHeadersCreateCompanionBuilder,
      $AdminHeadersUpdateCompanionBuilder,
      (
        AdminHeaderRow,
        BaseReferences<_$AppDatabase, AdminHeaders, AdminHeaderRow>,
      ),
      AdminHeaderRow,
      PrefetchHooks Function()
    >;
typedef $ModulesCatalogCreateCompanionBuilder =
    ModulesCatalogCompanion Function({
      required String key,
      required String label,
      required String description,
      Value<String?> dependsOn,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $ModulesCatalogUpdateCompanionBuilder =
    ModulesCatalogCompanion Function({
      Value<String> key,
      Value<String> label,
      Value<String> description,
      Value<String?> dependsOn,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $ModulesCatalogFilterComposer
    extends Composer<_$AppDatabase, ModulesCatalog> {
  $ModulesCatalogFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dependsOn => $composableBuilder(
    column: $table.dependsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $ModulesCatalogOrderingComposer
    extends Composer<_$AppDatabase, ModulesCatalog> {
  $ModulesCatalogOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dependsOn => $composableBuilder(
    column: $table.dependsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ModulesCatalogAnnotationComposer
    extends Composer<_$AppDatabase, ModulesCatalog> {
  $ModulesCatalogAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dependsOn =>
      $composableBuilder(column: $table.dependsOn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $ModulesCatalogTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ModulesCatalog,
          ModuleCatalogRow,
          $ModulesCatalogFilterComposer,
          $ModulesCatalogOrderingComposer,
          $ModulesCatalogAnnotationComposer,
          $ModulesCatalogCreateCompanionBuilder,
          $ModulesCatalogUpdateCompanionBuilder,
          (
            ModuleCatalogRow,
            BaseReferences<_$AppDatabase, ModulesCatalog, ModuleCatalogRow>,
          ),
          ModuleCatalogRow,
          PrefetchHooks Function()
        > {
  $ModulesCatalogTableManager(_$AppDatabase db, ModulesCatalog table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ModulesCatalogFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ModulesCatalogOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ModulesCatalogAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> dependsOn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModulesCatalogCompanion(
                key: key,
                label: label,
                description: description,
                dependsOn: dependsOn,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String label,
                required String description,
                Value<String?> dependsOn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModulesCatalogCompanion.insert(
                key: key,
                label: label,
                description: description,
                dependsOn: dependsOn,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ModulesCatalog, ModuleCatalogRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    ModulesCatalog,
                    ModuleCatalogRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ModulesCatalogProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ModulesCatalog,
      ModuleCatalogRow,
      $ModulesCatalogFilterComposer,
      $ModulesCatalogOrderingComposer,
      $ModulesCatalogAnnotationComposer,
      $ModulesCatalogCreateCompanionBuilder,
      $ModulesCatalogUpdateCompanionBuilder,
      (
        ModuleCatalogRow,
        BaseReferences<_$AppDatabase, ModulesCatalog, ModuleCatalogRow>,
      ),
      ModuleCatalogRow,
      PrefetchHooks Function()
    >;
typedef $SchoolModulesCreateCompanionBuilder = SchoolModulesCompanion Function({
  required String schoolId,
  required String moduleKey,
  Value<bool> enabled,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $SchoolModulesUpdateCompanionBuilder = SchoolModulesCompanion Function({
  Value<String> schoolId,
  Value<String> moduleKey,
  Value<bool> enabled,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $SchoolModulesFilterComposer
    extends Composer<_$AppDatabase, SchoolModules> {
  $SchoolModulesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moduleKey => $composableBuilder(
    column: $table.moduleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $SchoolModulesOrderingComposer
    extends Composer<_$AppDatabase, SchoolModules> {
  $SchoolModulesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moduleKey => $composableBuilder(
    column: $table.moduleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SchoolModulesAnnotationComposer
    extends Composer<_$AppDatabase, SchoolModules> {
  $SchoolModulesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get moduleKey =>
      $composableBuilder(column: $table.moduleKey, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $SchoolModulesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SchoolModules,
          SchoolModuleRow,
          $SchoolModulesFilterComposer,
          $SchoolModulesOrderingComposer,
          $SchoolModulesAnnotationComposer,
          $SchoolModulesCreateCompanionBuilder,
          $SchoolModulesUpdateCompanionBuilder,
          (
            SchoolModuleRow,
            BaseReferences<_$AppDatabase, SchoolModules, SchoolModuleRow>,
          ),
          SchoolModuleRow,
          PrefetchHooks Function()
        > {
  $SchoolModulesTableManager(_$AppDatabase db, SchoolModules table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SchoolModulesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SchoolModulesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SchoolModulesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> schoolId = const Value.absent(),
                Value<String> moduleKey = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolModulesCompanion(
                schoolId: schoolId,
                moduleKey: moduleKey,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String schoolId,
                required String moduleKey,
                Value<bool> enabled = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolModulesCompanion.insert(
                schoolId: schoolId,
                moduleKey: moduleKey,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SchoolModules, SchoolModuleRow>(table),
                  BaseReferences<_$AppDatabase, SchoolModules, SchoolModuleRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SchoolModulesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SchoolModules,
      SchoolModuleRow,
      $SchoolModulesFilterComposer,
      $SchoolModulesOrderingComposer,
      $SchoolModulesAnnotationComposer,
      $SchoolModulesCreateCompanionBuilder,
      $SchoolModulesUpdateCompanionBuilder,
      (
        SchoolModuleRow,
        BaseReferences<_$AppDatabase, SchoolModules, SchoolModuleRow>,
      ),
      SchoolModuleRow,
      PrefetchHooks Function()
    >;
typedef $MembershipsCreateCompanionBuilder = MembershipsCompanion Function({
  required String id,
  required String schoolId,
  required String userId,
  required String role,
  Value<String?> teacherId,
  required String displayName,
  Value<String?> phone,
  Value<bool> active,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $MembershipsUpdateCompanionBuilder = MembershipsCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> userId,
  Value<String> role,
  Value<String?> teacherId,
  Value<String> displayName,
  Value<String?> phone,
  Value<bool> active,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $MembershipsFilterComposer extends Composer<_$AppDatabase, Memberships> {
  $MembershipsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $MembershipsOrderingComposer
    extends Composer<_$AppDatabase, Memberships> {
  $MembershipsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $MembershipsAnnotationComposer
    extends Composer<_$AppDatabase, Memberships> {
  $MembershipsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $MembershipsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Memberships,
          MembershipRow,
          $MembershipsFilterComposer,
          $MembershipsOrderingComposer,
          $MembershipsAnnotationComposer,
          $MembershipsCreateCompanionBuilder,
          $MembershipsUpdateCompanionBuilder,
          (
            MembershipRow,
            BaseReferences<_$AppDatabase, Memberships, MembershipRow>,
          ),
          MembershipRow,
          PrefetchHooks Function()
        > {
  $MembershipsTableManager(_$AppDatabase db, Memberships table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MembershipsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MembershipsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MembershipsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> teacherId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembershipsCompanion(
                id: id,
                schoolId: schoolId,
                userId: userId,
                role: role,
                teacherId: teacherId,
                displayName: displayName,
                phone: phone,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String userId,
                required String role,
                Value<String?> teacherId = const Value.absent(),
                required String displayName,
                Value<String?> phone = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembershipsCompanion.insert(
                id: id,
                schoolId: schoolId,
                userId: userId,
                role: role,
                teacherId: teacherId,
                displayName: displayName,
                phone: phone,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Memberships, MembershipRow>(table),
                  BaseReferences<_$AppDatabase, Memberships, MembershipRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $MembershipsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Memberships,
      MembershipRow,
      $MembershipsFilterComposer,
      $MembershipsOrderingComposer,
      $MembershipsAnnotationComposer,
      $MembershipsCreateCompanionBuilder,
      $MembershipsUpdateCompanionBuilder,
      (
        MembershipRow,
        BaseReferences<_$AppDatabase, Memberships, MembershipRow>,
      ),
      MembershipRow,
      PrefetchHooks Function()
    >;
typedef $DelegatePermissionsCreateCompanionBuilder =
    DelegatePermissionsCompanion Function({
      required String id,
      required String schoolId,
      required String membershipId,
      required String permissionKey,
      Value<String?> createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });
typedef $DelegatePermissionsUpdateCompanionBuilder =
    DelegatePermissionsCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> membershipId,
      Value<String> permissionKey,
      Value<String?> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });

class $DelegatePermissionsFilterComposer
    extends Composer<_$AppDatabase, DelegatePermissions> {
  $DelegatePermissionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionKey => $composableBuilder(
    column: $table.permissionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $DelegatePermissionsOrderingComposer
    extends Composer<_$AppDatabase, DelegatePermissions> {
  $DelegatePermissionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionKey => $composableBuilder(
    column: $table.permissionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DelegatePermissionsAnnotationComposer
    extends Composer<_$AppDatabase, DelegatePermissions> {
  $DelegatePermissionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get permissionKey => $composableBuilder(
    column: $table.permissionKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $DelegatePermissionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          DelegatePermissions,
          DelegatePermissionRow,
          $DelegatePermissionsFilterComposer,
          $DelegatePermissionsOrderingComposer,
          $DelegatePermissionsAnnotationComposer,
          $DelegatePermissionsCreateCompanionBuilder,
          $DelegatePermissionsUpdateCompanionBuilder,
          (
            DelegatePermissionRow,
            BaseReferences<
              _$AppDatabase,
              DelegatePermissions,
              DelegatePermissionRow
            >,
          ),
          DelegatePermissionRow,
          PrefetchHooks Function()
        > {
  $DelegatePermissionsTableManager(_$AppDatabase db, DelegatePermissions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DelegatePermissionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DelegatePermissionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DelegatePermissionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> membershipId = const Value.absent(),
                Value<String> permissionKey = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DelegatePermissionsCompanion(
                id: id,
                schoolId: schoolId,
                membershipId: membershipId,
                permissionKey: permissionKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String membershipId,
                required String permissionKey,
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DelegatePermissionsCompanion.insert(
                id: id,
                schoolId: schoolId,
                membershipId: membershipId,
                permissionKey: permissionKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<DelegatePermissions, DelegatePermissionRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    DelegatePermissions,
                    DelegatePermissionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DelegatePermissionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      DelegatePermissions,
      DelegatePermissionRow,
      $DelegatePermissionsFilterComposer,
      $DelegatePermissionsOrderingComposer,
      $DelegatePermissionsAnnotationComposer,
      $DelegatePermissionsCreateCompanionBuilder,
      $DelegatePermissionsUpdateCompanionBuilder,
      (
        DelegatePermissionRow,
        BaseReferences<
          _$AppDatabase,
          DelegatePermissions,
          DelegatePermissionRow
        >,
      ),
      DelegatePermissionRow,
      PrefetchHooks Function()
    >;
typedef $DevicesCreateCompanionBuilder = DevicesCompanion Function({
  required String id,
  required String schoolId,
  Value<String?> userId,
  required String label,
  required String seriesCode,
  Value<String?> lastSeenAt,
  Value<String?> lastSyncAt,
  Value<int> pendingCount,
  Value<String?> appVersion,
  Value<String?> revokedAt,
  Value<String?> createdAt,
  Value<String?> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $DevicesUpdateCompanionBuilder = DevicesCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String?> userId,
  Value<String> label,
  Value<String> seriesCode,
  Value<String?> lastSeenAt,
  Value<String?> lastSyncAt,
  Value<int> pendingCount,
  Value<String?> appVersion,
  Value<String?> revokedAt,
  Value<String?> createdAt,
  Value<String?> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $DevicesFilterComposer extends Composer<_$AppDatabase, Devices> {
  $DevicesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesCode => $composableBuilder(
    column: $table.seriesCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingCount => $composableBuilder(
    column: $table.pendingCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $DevicesOrderingComposer extends Composer<_$AppDatabase, Devices> {
  $DevicesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesCode => $composableBuilder(
    column: $table.seriesCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingCount => $composableBuilder(
    column: $table.pendingCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DevicesAnnotationComposer extends Composer<_$AppDatabase, Devices> {
  $DevicesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get seriesCode => $composableBuilder(
    column: $table.seriesCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pendingCount => $composableBuilder(
    column: $table.pendingCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $DevicesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Devices,
          DeviceRow,
          $DevicesFilterComposer,
          $DevicesOrderingComposer,
          $DevicesAnnotationComposer,
          $DevicesCreateCompanionBuilder,
          $DevicesUpdateCompanionBuilder,
          (DeviceRow, BaseReferences<_$AppDatabase, Devices, DeviceRow>),
          DeviceRow,
          PrefetchHooks Function()
        > {
  $DevicesTableManager(_$AppDatabase db, Devices table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DevicesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DevicesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DevicesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> seriesCode = const Value.absent(),
                Value<String?> lastSeenAt = const Value.absent(),
                Value<String?> lastSyncAt = const Value.absent(),
                Value<int> pendingCount = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<String?> revokedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                schoolId: schoolId,
                userId: userId,
                label: label,
                seriesCode: seriesCode,
                lastSeenAt: lastSeenAt,
                lastSyncAt: lastSyncAt,
                pendingCount: pendingCount,
                appVersion: appVersion,
                revokedAt: revokedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                Value<String?> userId = const Value.absent(),
                required String label,
                required String seriesCode,
                Value<String?> lastSeenAt = const Value.absent(),
                Value<String?> lastSyncAt = const Value.absent(),
                Value<int> pendingCount = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<String?> revokedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                schoolId: schoolId,
                userId: userId,
                label: label,
                seriesCode: seriesCode,
                lastSeenAt: lastSeenAt,
                lastSyncAt: lastSyncAt,
                pendingCount: pendingCount,
                appVersion: appVersion,
                revokedAt: revokedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Devices, DeviceRow>(table),
                  BaseReferences<_$AppDatabase, Devices, DeviceRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DevicesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Devices,
      DeviceRow,
      $DevicesFilterComposer,
      $DevicesOrderingComposer,
      $DevicesAnnotationComposer,
      $DevicesCreateCompanionBuilder,
      $DevicesUpdateCompanionBuilder,
      (DeviceRow, BaseReferences<_$AppDatabase, Devices, DeviceRow>),
      DeviceRow,
      PrefetchHooks Function()
    >;
typedef $AuditLogCreateCompanionBuilder = AuditLogCompanion Function({
  required String id,
  required String schoolId,
  required String occurredAt,
  Value<String?> actorId,
  required String action,
  Value<String?> affectedTable,
  Value<String?> rowId,
  Value<String?> details,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $AuditLogUpdateCompanionBuilder = AuditLogCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> occurredAt,
  Value<String?> actorId,
  Value<String> action,
  Value<String?> affectedTable,
  Value<String?> rowId,
  Value<String?> details,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $AuditLogFilterComposer extends Composer<_$AppDatabase, AuditLog> {
  $AuditLogFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get affectedTable => $composableBuilder(
    column: $table.affectedTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $AuditLogOrderingComposer extends Composer<_$AppDatabase, AuditLog> {
  $AuditLogOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get affectedTable => $composableBuilder(
    column: $table.affectedTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AuditLogAnnotationComposer extends Composer<_$AppDatabase, AuditLog> {
  $AuditLogAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get affectedTable => $composableBuilder(
    column: $table.affectedTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $AuditLogTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          AuditLog,
          AuditRow,
          $AuditLogFilterComposer,
          $AuditLogOrderingComposer,
          $AuditLogAnnotationComposer,
          $AuditLogCreateCompanionBuilder,
          $AuditLogUpdateCompanionBuilder,
          (AuditRow, BaseReferences<_$AppDatabase, AuditLog, AuditRow>),
          AuditRow,
          PrefetchHooks Function()
        > {
  $AuditLogTableManager(_$AppDatabase db, AuditLog table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AuditLogFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AuditLogOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AuditLogAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> occurredAt = const Value.absent(),
                Value<String?> actorId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> affectedTable = const Value.absent(),
                Value<String?> rowId = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion(
                id: id,
                schoolId: schoolId,
                occurredAt: occurredAt,
                actorId: actorId,
                action: action,
                affectedTable: affectedTable,
                rowId: rowId,
                details: details,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String occurredAt,
                Value<String?> actorId = const Value.absent(),
                required String action,
                Value<String?> affectedTable = const Value.absent(),
                Value<String?> rowId = const Value.absent(),
                Value<String?> details = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogCompanion.insert(
                id: id,
                schoolId: schoolId,
                occurredAt: occurredAt,
                actorId: actorId,
                action: action,
                affectedTable: affectedTable,
                rowId: rowId,
                details: details,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AuditLog, AuditRow>(table),
                  BaseReferences<_$AppDatabase, AuditLog, AuditRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AuditLogProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      AuditLog,
      AuditRow,
      $AuditLogFilterComposer,
      $AuditLogOrderingComposer,
      $AuditLogAnnotationComposer,
      $AuditLogCreateCompanionBuilder,
      $AuditLogUpdateCompanionBuilder,
      (AuditRow, BaseReferences<_$AppDatabase, AuditLog, AuditRow>),
      AuditRow,
      PrefetchHooks Function()
    >;
typedef $LevelsCreateCompanionBuilder = LevelsCompanion Function({
  required String code,
  required String cycle,
  required String label,
  required int sortOrder,
  Value<int> rowid,
});
typedef $LevelsUpdateCompanionBuilder = LevelsCompanion Function({
  Value<String> code,
  Value<String> cycle,
  Value<String> label,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $LevelsFilterComposer extends Composer<_$AppDatabase, Levels> {
  $LevelsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $LevelsOrderingComposer extends Composer<_$AppDatabase, Levels> {
  $LevelsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cycle => $composableBuilder(
    column: $table.cycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $LevelsAnnotationComposer extends Composer<_$AppDatabase, Levels> {
  $LevelsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get cycle =>
      $composableBuilder(column: $table.cycle, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $LevelsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Levels,
          LevelRow,
          $LevelsFilterComposer,
          $LevelsOrderingComposer,
          $LevelsAnnotationComposer,
          $LevelsCreateCompanionBuilder,
          $LevelsUpdateCompanionBuilder,
          (LevelRow, BaseReferences<_$AppDatabase, Levels, LevelRow>),
          LevelRow,
          PrefetchHooks Function()
        > {
  $LevelsTableManager(_$AppDatabase db, Levels table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LevelsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LevelsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LevelsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> cycle = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LevelsCompanion(
                code: code,
                cycle: cycle,
                label: label,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String cycle,
                required String label,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => LevelsCompanion.insert(
                code: code,
                cycle: cycle,
                label: label,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Levels, LevelRow>(table),
                  BaseReferences<_$AppDatabase, Levels, LevelRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $LevelsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Levels,
      LevelRow,
      $LevelsFilterComposer,
      $LevelsOrderingComposer,
      $LevelsAnnotationComposer,
      $LevelsCreateCompanionBuilder,
      $LevelsUpdateCompanionBuilder,
      (LevelRow, BaseReferences<_$AppDatabase, Levels, LevelRow>),
      LevelRow,
      PrefetchHooks Function()
    >;
typedef $TeachersCreateCompanionBuilder = TeachersCompanion Function({
  required String id,
  required String schoolId,
  required String lastName,
  required String firstNames,
  Value<String?> sex,
  Value<String?> matricule,
  Value<String?> phone,
  Value<String?> birthDate,
  Value<String?> birthPlace,
  Value<String?> emploi,
  Value<String?> categorie,
  Value<String?> echelon,
  Value<String?> tenureStatus,
  Value<String> status,
  Value<String?> communeNominationDate,
  Value<String?> firstTeachingNominationDate,
  Value<String?> pupilSchoolName,
  Value<String?> pupilSchoolEntryDate,
  Value<String?> pupilSchoolExitDate,
  Value<String?> seniorityGeneralFrom,
  Value<String?> seniorityEmploiFrom,
  Value<String?> seniorityRegionFrom,
  Value<String?> seniorityFonctionFrom,
  Value<String?> communeCessationDate,
  Value<String?> newPost,
  Value<String?> observations,
  Value<String?> archivedAt,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $TeachersUpdateCompanionBuilder = TeachersCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> lastName,
  Value<String> firstNames,
  Value<String?> sex,
  Value<String?> matricule,
  Value<String?> phone,
  Value<String?> birthDate,
  Value<String?> birthPlace,
  Value<String?> emploi,
  Value<String?> categorie,
  Value<String?> echelon,
  Value<String?> tenureStatus,
  Value<String> status,
  Value<String?> communeNominationDate,
  Value<String?> firstTeachingNominationDate,
  Value<String?> pupilSchoolName,
  Value<String?> pupilSchoolEntryDate,
  Value<String?> pupilSchoolExitDate,
  Value<String?> seniorityGeneralFrom,
  Value<String?> seniorityEmploiFrom,
  Value<String?> seniorityRegionFrom,
  Value<String?> seniorityFonctionFrom,
  Value<String?> communeCessationDate,
  Value<String?> newPost,
  Value<String?> observations,
  Value<String?> archivedAt,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $TeachersFilterComposer extends Composer<_$AppDatabase, Teachers> {
  $TeachersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstNames => $composableBuilder(
    column: $table.firstNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matricule => $composableBuilder(
    column: $table.matricule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emploi => $composableBuilder(
    column: $table.emploi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categorie => $composableBuilder(
    column: $table.categorie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get echelon => $composableBuilder(
    column: $table.echelon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenureStatus => $composableBuilder(
    column: $table.tenureStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get communeNominationDate => $composableBuilder(
    column: $table.communeNominationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstTeachingNominationDate => $composableBuilder(
    column: $table.firstTeachingNominationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pupilSchoolName => $composableBuilder(
    column: $table.pupilSchoolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pupilSchoolEntryDate => $composableBuilder(
    column: $table.pupilSchoolEntryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pupilSchoolExitDate => $composableBuilder(
    column: $table.pupilSchoolExitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seniorityGeneralFrom => $composableBuilder(
    column: $table.seniorityGeneralFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seniorityEmploiFrom => $composableBuilder(
    column: $table.seniorityEmploiFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seniorityRegionFrom => $composableBuilder(
    column: $table.seniorityRegionFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seniorityFonctionFrom => $composableBuilder(
    column: $table.seniorityFonctionFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get communeCessationDate => $composableBuilder(
    column: $table.communeCessationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newPost => $composableBuilder(
    column: $table.newPost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $TeachersOrderingComposer extends Composer<_$AppDatabase, Teachers> {
  $TeachersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstNames => $composableBuilder(
    column: $table.firstNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matricule => $composableBuilder(
    column: $table.matricule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emploi => $composableBuilder(
    column: $table.emploi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorie => $composableBuilder(
    column: $table.categorie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get echelon => $composableBuilder(
    column: $table.echelon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenureStatus => $composableBuilder(
    column: $table.tenureStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get communeNominationDate => $composableBuilder(
    column: $table.communeNominationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstTeachingNominationDate => $composableBuilder(
    column: $table.firstTeachingNominationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pupilSchoolName => $composableBuilder(
    column: $table.pupilSchoolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pupilSchoolEntryDate => $composableBuilder(
    column: $table.pupilSchoolEntryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pupilSchoolExitDate => $composableBuilder(
    column: $table.pupilSchoolExitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seniorityGeneralFrom => $composableBuilder(
    column: $table.seniorityGeneralFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seniorityEmploiFrom => $composableBuilder(
    column: $table.seniorityEmploiFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seniorityRegionFrom => $composableBuilder(
    column: $table.seniorityRegionFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seniorityFonctionFrom => $composableBuilder(
    column: $table.seniorityFonctionFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get communeCessationDate => $composableBuilder(
    column: $table.communeCessationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newPost => $composableBuilder(
    column: $table.newPost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TeachersAnnotationComposer extends Composer<_$AppDatabase, Teachers> {
  $TeachersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get firstNames => $composableBuilder(
    column: $table.firstNames,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get matricule =>
      $composableBuilder(column: $table.matricule, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emploi =>
      $composableBuilder(column: $table.emploi, builder: (column) => column);

  GeneratedColumn<String> get categorie =>
      $composableBuilder(column: $table.categorie, builder: (column) => column);

  GeneratedColumn<String> get echelon =>
      $composableBuilder(column: $table.echelon, builder: (column) => column);

  GeneratedColumn<String> get tenureStatus => $composableBuilder(
    column: $table.tenureStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get communeNominationDate => $composableBuilder(
    column: $table.communeNominationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstTeachingNominationDate => $composableBuilder(
    column: $table.firstTeachingNominationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pupilSchoolName => $composableBuilder(
    column: $table.pupilSchoolName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pupilSchoolEntryDate => $composableBuilder(
    column: $table.pupilSchoolEntryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pupilSchoolExitDate => $composableBuilder(
    column: $table.pupilSchoolExitDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seniorityGeneralFrom => $composableBuilder(
    column: $table.seniorityGeneralFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seniorityEmploiFrom => $composableBuilder(
    column: $table.seniorityEmploiFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seniorityRegionFrom => $composableBuilder(
    column: $table.seniorityRegionFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seniorityFonctionFrom => $composableBuilder(
    column: $table.seniorityFonctionFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get communeCessationDate => $composableBuilder(
    column: $table.communeCessationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newPost =>
      $composableBuilder(column: $table.newPost, builder: (column) => column);

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $TeachersTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Teachers,
          TeacherRow,
          $TeachersFilterComposer,
          $TeachersOrderingComposer,
          $TeachersAnnotationComposer,
          $TeachersCreateCompanionBuilder,
          $TeachersUpdateCompanionBuilder,
          (TeacherRow, BaseReferences<_$AppDatabase, Teachers, TeacherRow>),
          TeacherRow,
          PrefetchHooks Function()
        > {
  $TeachersTableManager(_$AppDatabase db, Teachers table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TeachersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TeachersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TeachersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> firstNames = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> matricule = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> emploi = const Value.absent(),
                Value<String?> categorie = const Value.absent(),
                Value<String?> echelon = const Value.absent(),
                Value<String?> tenureStatus = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> communeNominationDate = const Value.absent(),
                Value<String?> firstTeachingNominationDate =
                    const Value.absent(),
                Value<String?> pupilSchoolName = const Value.absent(),
                Value<String?> pupilSchoolEntryDate = const Value.absent(),
                Value<String?> pupilSchoolExitDate = const Value.absent(),
                Value<String?> seniorityGeneralFrom = const Value.absent(),
                Value<String?> seniorityEmploiFrom = const Value.absent(),
                Value<String?> seniorityRegionFrom = const Value.absent(),
                Value<String?> seniorityFonctionFrom = const Value.absent(),
                Value<String?> communeCessationDate = const Value.absent(),
                Value<String?> newPost = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeachersCompanion(
                id: id,
                schoolId: schoolId,
                lastName: lastName,
                firstNames: firstNames,
                sex: sex,
                matricule: matricule,
                phone: phone,
                birthDate: birthDate,
                birthPlace: birthPlace,
                emploi: emploi,
                categorie: categorie,
                echelon: echelon,
                tenureStatus: tenureStatus,
                status: status,
                communeNominationDate: communeNominationDate,
                firstTeachingNominationDate: firstTeachingNominationDate,
                pupilSchoolName: pupilSchoolName,
                pupilSchoolEntryDate: pupilSchoolEntryDate,
                pupilSchoolExitDate: pupilSchoolExitDate,
                seniorityGeneralFrom: seniorityGeneralFrom,
                seniorityEmploiFrom: seniorityEmploiFrom,
                seniorityRegionFrom: seniorityRegionFrom,
                seniorityFonctionFrom: seniorityFonctionFrom,
                communeCessationDate: communeCessationDate,
                newPost: newPost,
                observations: observations,
                archivedAt: archivedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String lastName,
                required String firstNames,
                Value<String?> sex = const Value.absent(),
                Value<String?> matricule = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> emploi = const Value.absent(),
                Value<String?> categorie = const Value.absent(),
                Value<String?> echelon = const Value.absent(),
                Value<String?> tenureStatus = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> communeNominationDate = const Value.absent(),
                Value<String?> firstTeachingNominationDate =
                    const Value.absent(),
                Value<String?> pupilSchoolName = const Value.absent(),
                Value<String?> pupilSchoolEntryDate = const Value.absent(),
                Value<String?> pupilSchoolExitDate = const Value.absent(),
                Value<String?> seniorityGeneralFrom = const Value.absent(),
                Value<String?> seniorityEmploiFrom = const Value.absent(),
                Value<String?> seniorityRegionFrom = const Value.absent(),
                Value<String?> seniorityFonctionFrom = const Value.absent(),
                Value<String?> communeCessationDate = const Value.absent(),
                Value<String?> newPost = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeachersCompanion.insert(
                id: id,
                schoolId: schoolId,
                lastName: lastName,
                firstNames: firstNames,
                sex: sex,
                matricule: matricule,
                phone: phone,
                birthDate: birthDate,
                birthPlace: birthPlace,
                emploi: emploi,
                categorie: categorie,
                echelon: echelon,
                tenureStatus: tenureStatus,
                status: status,
                communeNominationDate: communeNominationDate,
                firstTeachingNominationDate: firstTeachingNominationDate,
                pupilSchoolName: pupilSchoolName,
                pupilSchoolEntryDate: pupilSchoolEntryDate,
                pupilSchoolExitDate: pupilSchoolExitDate,
                seniorityGeneralFrom: seniorityGeneralFrom,
                seniorityEmploiFrom: seniorityEmploiFrom,
                seniorityRegionFrom: seniorityRegionFrom,
                seniorityFonctionFrom: seniorityFonctionFrom,
                communeCessationDate: communeCessationDate,
                newPost: newPost,
                observations: observations,
                archivedAt: archivedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Teachers, TeacherRow>(table),
                  BaseReferences<_$AppDatabase, Teachers, TeacherRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TeachersProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Teachers,
      TeacherRow,
      $TeachersFilterComposer,
      $TeachersOrderingComposer,
      $TeachersAnnotationComposer,
      $TeachersCreateCompanionBuilder,
      $TeachersUpdateCompanionBuilder,
      (TeacherRow, BaseReferences<_$AppDatabase, Teachers, TeacherRow>),
      TeacherRow,
      PrefetchHooks Function()
    >;
typedef $TeacherPostingsCreateCompanionBuilder =
    TeacherPostingsCompanion Function({
      required String id,
      required String schoolId,
      required String teacherId,
      required String commune,
      Value<String?> nominatedOn,
      Value<int> sortOrder,
      Value<String?> createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });
typedef $TeacherPostingsUpdateCompanionBuilder =
    TeacherPostingsCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> teacherId,
      Value<String> commune,
      Value<String?> nominatedOn,
      Value<int> sortOrder,
      Value<String?> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });

class $TeacherPostingsFilterComposer
    extends Composer<_$AppDatabase, TeacherPostings> {
  $TeacherPostingsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nominatedOn => $composableBuilder(
    column: $table.nominatedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $TeacherPostingsOrderingComposer
    extends Composer<_$AppDatabase, TeacherPostings> {
  $TeacherPostingsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nominatedOn => $composableBuilder(
    column: $table.nominatedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TeacherPostingsAnnotationComposer
    extends Composer<_$AppDatabase, TeacherPostings> {
  $TeacherPostingsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get commune =>
      $composableBuilder(column: $table.commune, builder: (column) => column);

  GeneratedColumn<String> get nominatedOn => $composableBuilder(
    column: $table.nominatedOn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $TeacherPostingsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          TeacherPostings,
          TeacherPostingRow,
          $TeacherPostingsFilterComposer,
          $TeacherPostingsOrderingComposer,
          $TeacherPostingsAnnotationComposer,
          $TeacherPostingsCreateCompanionBuilder,
          $TeacherPostingsUpdateCompanionBuilder,
          (
            TeacherPostingRow,
            BaseReferences<_$AppDatabase, TeacherPostings, TeacherPostingRow>,
          ),
          TeacherPostingRow,
          PrefetchHooks Function()
        > {
  $TeacherPostingsTableManager(_$AppDatabase db, TeacherPostings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TeacherPostingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TeacherPostingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TeacherPostingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<String> commune = const Value.absent(),
                Value<String?> nominatedOn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherPostingsCompanion(
                id: id,
                schoolId: schoolId,
                teacherId: teacherId,
                commune: commune,
                nominatedOn: nominatedOn,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String teacherId,
                required String commune,
                Value<String?> nominatedOn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherPostingsCompanion.insert(
                id: id,
                schoolId: schoolId,
                teacherId: teacherId,
                commune: commune,
                nominatedOn: nominatedOn,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TeacherPostings, TeacherPostingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    TeacherPostings,
                    TeacherPostingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TeacherPostingsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      TeacherPostings,
      TeacherPostingRow,
      $TeacherPostingsFilterComposer,
      $TeacherPostingsOrderingComposer,
      $TeacherPostingsAnnotationComposer,
      $TeacherPostingsCreateCompanionBuilder,
      $TeacherPostingsUpdateCompanionBuilder,
      (
        TeacherPostingRow,
        BaseReferences<_$AppDatabase, TeacherPostings, TeacherPostingRow>,
      ),
      TeacherPostingRow,
      PrefetchHooks Function()
    >;
typedef $TeacherInterruptionsCreateCompanionBuilder =
    TeacherInterruptionsCompanion Function({
      required String id,
      required String schoolId,
      required String teacherId,
      required String cause,
      Value<String?> startsOn,
      Value<String?> endsOn,
      Value<String?> durationText,
      Value<String?> createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });
typedef $TeacherInterruptionsUpdateCompanionBuilder =
    TeacherInterruptionsCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> teacherId,
      Value<String> cause,
      Value<String?> startsOn,
      Value<String?> endsOn,
      Value<String?> durationText,
      Value<String?> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });

class $TeacherInterruptionsFilterComposer
    extends Composer<_$AppDatabase, TeacherInterruptions> {
  $TeacherInterruptionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cause => $composableBuilder(
    column: $table.cause,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get durationText => $composableBuilder(
    column: $table.durationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $TeacherInterruptionsOrderingComposer
    extends Composer<_$AppDatabase, TeacherInterruptions> {
  $TeacherInterruptionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cause => $composableBuilder(
    column: $table.cause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get durationText => $composableBuilder(
    column: $table.durationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TeacherInterruptionsAnnotationComposer
    extends Composer<_$AppDatabase, TeacherInterruptions> {
  $TeacherInterruptionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get cause =>
      $composableBuilder(column: $table.cause, builder: (column) => column);

  GeneratedColumn<String> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<String> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<String> get durationText => $composableBuilder(
    column: $table.durationText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $TeacherInterruptionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          TeacherInterruptions,
          TeacherInterruptionRow,
          $TeacherInterruptionsFilterComposer,
          $TeacherInterruptionsOrderingComposer,
          $TeacherInterruptionsAnnotationComposer,
          $TeacherInterruptionsCreateCompanionBuilder,
          $TeacherInterruptionsUpdateCompanionBuilder,
          (
            TeacherInterruptionRow,
            BaseReferences<
              _$AppDatabase,
              TeacherInterruptions,
              TeacherInterruptionRow
            >,
          ),
          TeacherInterruptionRow,
          PrefetchHooks Function()
        > {
  $TeacherInterruptionsTableManager(
    _$AppDatabase db,
    TeacherInterruptions table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TeacherInterruptionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TeacherInterruptionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TeacherInterruptionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<String> cause = const Value.absent(),
                Value<String?> startsOn = const Value.absent(),
                Value<String?> endsOn = const Value.absent(),
                Value<String?> durationText = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherInterruptionsCompanion(
                id: id,
                schoolId: schoolId,
                teacherId: teacherId,
                cause: cause,
                startsOn: startsOn,
                endsOn: endsOn,
                durationText: durationText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String teacherId,
                required String cause,
                Value<String?> startsOn = const Value.absent(),
                Value<String?> endsOn = const Value.absent(),
                Value<String?> durationText = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherInterruptionsCompanion.insert(
                id: id,
                schoolId: schoolId,
                teacherId: teacherId,
                cause: cause,
                startsOn: startsOn,
                endsOn: endsOn,
                durationText: durationText,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TeacherInterruptions, TeacherInterruptionRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    TeacherInterruptions,
                    TeacherInterruptionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TeacherInterruptionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      TeacherInterruptions,
      TeacherInterruptionRow,
      $TeacherInterruptionsFilterComposer,
      $TeacherInterruptionsOrderingComposer,
      $TeacherInterruptionsAnnotationComposer,
      $TeacherInterruptionsCreateCompanionBuilder,
      $TeacherInterruptionsUpdateCompanionBuilder,
      (
        TeacherInterruptionRow,
        BaseReferences<
          _$AppDatabase,
          TeacherInterruptions,
          TeacherInterruptionRow
        >,
      ),
      TeacherInterruptionRow,
      PrefetchHooks Function()
    >;
typedef $TeacherAwardsCreateCompanionBuilder = TeacherAwardsCompanion Function({
  required String id,
  required String schoolId,
  required String teacherId,
  required String label,
  Value<String?> awardedOn,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $TeacherAwardsUpdateCompanionBuilder = TeacherAwardsCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> teacherId,
  Value<String> label,
  Value<String?> awardedOn,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $TeacherAwardsFilterComposer
    extends Composer<_$AppDatabase, TeacherAwards> {
  $TeacherAwardsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get awardedOn => $composableBuilder(
    column: $table.awardedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $TeacherAwardsOrderingComposer
    extends Composer<_$AppDatabase, TeacherAwards> {
  $TeacherAwardsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get awardedOn => $composableBuilder(
    column: $table.awardedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TeacherAwardsAnnotationComposer
    extends Composer<_$AppDatabase, TeacherAwards> {
  $TeacherAwardsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get awardedOn =>
      $composableBuilder(column: $table.awardedOn, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $TeacherAwardsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          TeacherAwards,
          TeacherAwardRow,
          $TeacherAwardsFilterComposer,
          $TeacherAwardsOrderingComposer,
          $TeacherAwardsAnnotationComposer,
          $TeacherAwardsCreateCompanionBuilder,
          $TeacherAwardsUpdateCompanionBuilder,
          (
            TeacherAwardRow,
            BaseReferences<_$AppDatabase, TeacherAwards, TeacherAwardRow>,
          ),
          TeacherAwardRow,
          PrefetchHooks Function()
        > {
  $TeacherAwardsTableManager(_$AppDatabase db, TeacherAwards table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TeacherAwardsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TeacherAwardsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TeacherAwardsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> awardedOn = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherAwardsCompanion(
                id: id,
                schoolId: schoolId,
                teacherId: teacherId,
                label: label,
                awardedOn: awardedOn,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String teacherId,
                required String label,
                Value<String?> awardedOn = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherAwardsCompanion.insert(
                id: id,
                schoolId: schoolId,
                teacherId: teacherId,
                label: label,
                awardedOn: awardedOn,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TeacherAwards, TeacherAwardRow>(table),
                  BaseReferences<_$AppDatabase, TeacherAwards, TeacherAwardRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TeacherAwardsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      TeacherAwards,
      TeacherAwardRow,
      $TeacherAwardsFilterComposer,
      $TeacherAwardsOrderingComposer,
      $TeacherAwardsAnnotationComposer,
      $TeacherAwardsCreateCompanionBuilder,
      $TeacherAwardsUpdateCompanionBuilder,
      (
        TeacherAwardRow,
        BaseReferences<_$AppDatabase, TeacherAwards, TeacherAwardRow>,
      ),
      TeacherAwardRow,
      PrefetchHooks Function()
    >;
typedef $TeacherDiplomasCreateCompanionBuilder =
    TeacherDiplomasCompanion Function({
      required String id,
      required String schoolId,
      required String teacherId,
      required String nature,
      Value<String?> deliveredOn,
      Value<bool> isAcademic,
      Value<String?> createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });
typedef $TeacherDiplomasUpdateCompanionBuilder =
    TeacherDiplomasCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> teacherId,
      Value<String> nature,
      Value<String?> deliveredOn,
      Value<bool> isAcademic,
      Value<String?> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });

class $TeacherDiplomasFilterComposer
    extends Composer<_$AppDatabase, TeacherDiplomas> {
  $TeacherDiplomasFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nature => $composableBuilder(
    column: $table.nature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveredOn => $composableBuilder(
    column: $table.deliveredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAcademic => $composableBuilder(
    column: $table.isAcademic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $TeacherDiplomasOrderingComposer
    extends Composer<_$AppDatabase, TeacherDiplomas> {
  $TeacherDiplomasOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nature => $composableBuilder(
    column: $table.nature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveredOn => $composableBuilder(
    column: $table.deliveredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAcademic => $composableBuilder(
    column: $table.isAcademic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TeacherDiplomasAnnotationComposer
    extends Composer<_$AppDatabase, TeacherDiplomas> {
  $TeacherDiplomasAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get nature =>
      $composableBuilder(column: $table.nature, builder: (column) => column);

  GeneratedColumn<String> get deliveredOn => $composableBuilder(
    column: $table.deliveredOn,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAcademic => $composableBuilder(
    column: $table.isAcademic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $TeacherDiplomasTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          TeacherDiplomas,
          TeacherDiplomaRow,
          $TeacherDiplomasFilterComposer,
          $TeacherDiplomasOrderingComposer,
          $TeacherDiplomasAnnotationComposer,
          $TeacherDiplomasCreateCompanionBuilder,
          $TeacherDiplomasUpdateCompanionBuilder,
          (
            TeacherDiplomaRow,
            BaseReferences<_$AppDatabase, TeacherDiplomas, TeacherDiplomaRow>,
          ),
          TeacherDiplomaRow,
          PrefetchHooks Function()
        > {
  $TeacherDiplomasTableManager(_$AppDatabase db, TeacherDiplomas table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TeacherDiplomasFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TeacherDiplomasOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TeacherDiplomasAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<String> nature = const Value.absent(),
                Value<String?> deliveredOn = const Value.absent(),
                Value<bool> isAcademic = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherDiplomasCompanion(
                id: id,
                schoolId: schoolId,
                teacherId: teacherId,
                nature: nature,
                deliveredOn: deliveredOn,
                isAcademic: isAcademic,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String teacherId,
                required String nature,
                Value<String?> deliveredOn = const Value.absent(),
                Value<bool> isAcademic = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherDiplomasCompanion.insert(
                id: id,
                schoolId: schoolId,
                teacherId: teacherId,
                nature: nature,
                deliveredOn: deliveredOn,
                isAcademic: isAcademic,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TeacherDiplomas, TeacherDiplomaRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    TeacherDiplomas,
                    TeacherDiplomaRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TeacherDiplomasProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      TeacherDiplomas,
      TeacherDiplomaRow,
      $TeacherDiplomasFilterComposer,
      $TeacherDiplomasOrderingComposer,
      $TeacherDiplomasAnnotationComposer,
      $TeacherDiplomasCreateCompanionBuilder,
      $TeacherDiplomasUpdateCompanionBuilder,
      (
        TeacherDiplomaRow,
        BaseReferences<_$AppDatabase, TeacherDiplomas, TeacherDiplomaRow>,
      ),
      TeacherDiplomaRow,
      PrefetchHooks Function()
    >;
typedef $ClassesCreateCompanionBuilder = ClassesCompanion Function({
  required String id,
  required String schoolId,
  required String schoolYearId,
  required String levelCode,
  required String name,
  Value<String?> mainTeacherId,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $ClassesUpdateCompanionBuilder = ClassesCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> schoolYearId,
  Value<String> levelCode,
  Value<String> name,
  Value<String?> mainTeacherId,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $ClassesFilterComposer extends Composer<_$AppDatabase, Classes> {
  $ClassesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelCode => $composableBuilder(
    column: $table.levelCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mainTeacherId => $composableBuilder(
    column: $table.mainTeacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $ClassesOrderingComposer extends Composer<_$AppDatabase, Classes> {
  $ClassesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelCode => $composableBuilder(
    column: $table.levelCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mainTeacherId => $composableBuilder(
    column: $table.mainTeacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ClassesAnnotationComposer extends Composer<_$AppDatabase, Classes> {
  $ClassesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get levelCode =>
      $composableBuilder(column: $table.levelCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mainTeacherId => $composableBuilder(
    column: $table.mainTeacherId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $ClassesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Classes,
          ClassRow,
          $ClassesFilterComposer,
          $ClassesOrderingComposer,
          $ClassesAnnotationComposer,
          $ClassesCreateCompanionBuilder,
          $ClassesUpdateCompanionBuilder,
          (ClassRow, BaseReferences<_$AppDatabase, Classes, ClassRow>),
          ClassRow,
          PrefetchHooks Function()
        > {
  $ClassesTableManager(_$AppDatabase db, Classes table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ClassesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ClassesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ClassesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> schoolYearId = const Value.absent(),
                Value<String> levelCode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> mainTeacherId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassesCompanion(
                id: id,
                schoolId: schoolId,
                schoolYearId: schoolYearId,
                levelCode: levelCode,
                name: name,
                mainTeacherId: mainTeacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String schoolYearId,
                required String levelCode,
                required String name,
                Value<String?> mainTeacherId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassesCompanion.insert(
                id: id,
                schoolId: schoolId,
                schoolYearId: schoolYearId,
                levelCode: levelCode,
                name: name,
                mainTeacherId: mainTeacherId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Classes, ClassRow>(table),
                  BaseReferences<_$AppDatabase, Classes, ClassRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ClassesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Classes,
      ClassRow,
      $ClassesFilterComposer,
      $ClassesOrderingComposer,
      $ClassesAnnotationComposer,
      $ClassesCreateCompanionBuilder,
      $ClassesUpdateCompanionBuilder,
      (ClassRow, BaseReferences<_$AppDatabase, Classes, ClassRow>),
      ClassRow,
      PrefetchHooks Function()
    >;
typedef $TeacherYearAssignmentsCreateCompanionBuilder =
    TeacherYearAssignmentsCompanion Function({
      required String id,
      required String schoolId,
      required String schoolYearId,
      required String teacherId,
      Value<String?> classId,
      Value<String?> serviceLabel,
      Value<String?> fonction,
      Value<String?> createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });
typedef $TeacherYearAssignmentsUpdateCompanionBuilder =
    TeacherYearAssignmentsCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String> schoolYearId,
      Value<String> teacherId,
      Value<String?> classId,
      Value<String?> serviceLabel,
      Value<String?> fonction,
      Value<String?> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });

class $TeacherYearAssignmentsFilterComposer
    extends Composer<_$AppDatabase, TeacherYearAssignments> {
  $TeacherYearAssignmentsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceLabel => $composableBuilder(
    column: $table.serviceLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fonction => $composableBuilder(
    column: $table.fonction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $TeacherYearAssignmentsOrderingComposer
    extends Composer<_$AppDatabase, TeacherYearAssignments> {
  $TeacherYearAssignmentsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceLabel => $composableBuilder(
    column: $table.serviceLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fonction => $composableBuilder(
    column: $table.fonction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TeacherYearAssignmentsAnnotationComposer
    extends Composer<_$AppDatabase, TeacherYearAssignments> {
  $TeacherYearAssignmentsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get serviceLabel => $composableBuilder(
    column: $table.serviceLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fonction =>
      $composableBuilder(column: $table.fonction, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $TeacherYearAssignmentsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          TeacherYearAssignments,
          TeacherAssignmentRow,
          $TeacherYearAssignmentsFilterComposer,
          $TeacherYearAssignmentsOrderingComposer,
          $TeacherYearAssignmentsAnnotationComposer,
          $TeacherYearAssignmentsCreateCompanionBuilder,
          $TeacherYearAssignmentsUpdateCompanionBuilder,
          (
            TeacherAssignmentRow,
            BaseReferences<
              _$AppDatabase,
              TeacherYearAssignments,
              TeacherAssignmentRow
            >,
          ),
          TeacherAssignmentRow,
          PrefetchHooks Function()
        > {
  $TeacherYearAssignmentsTableManager(
    _$AppDatabase db,
    TeacherYearAssignments table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TeacherYearAssignmentsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TeacherYearAssignmentsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TeacherYearAssignmentsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> schoolYearId = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<String?> classId = const Value.absent(),
                Value<String?> serviceLabel = const Value.absent(),
                Value<String?> fonction = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherYearAssignmentsCompanion(
                id: id,
                schoolId: schoolId,
                schoolYearId: schoolYearId,
                teacherId: teacherId,
                classId: classId,
                serviceLabel: serviceLabel,
                fonction: fonction,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String schoolYearId,
                required String teacherId,
                Value<String?> classId = const Value.absent(),
                Value<String?> serviceLabel = const Value.absent(),
                Value<String?> fonction = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherYearAssignmentsCompanion.insert(
                id: id,
                schoolId: schoolId,
                schoolYearId: schoolYearId,
                teacherId: teacherId,
                classId: classId,
                serviceLabel: serviceLabel,
                fonction: fonction,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TeacherYearAssignments, TeacherAssignmentRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    TeacherYearAssignments,
                    TeacherAssignmentRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TeacherYearAssignmentsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      TeacherYearAssignments,
      TeacherAssignmentRow,
      $TeacherYearAssignmentsFilterComposer,
      $TeacherYearAssignmentsOrderingComposer,
      $TeacherYearAssignmentsAnnotationComposer,
      $TeacherYearAssignmentsCreateCompanionBuilder,
      $TeacherYearAssignmentsUpdateCompanionBuilder,
      (
        TeacherAssignmentRow,
        BaseReferences<
          _$AppDatabase,
          TeacherYearAssignments,
          TeacherAssignmentRow
        >,
      ),
      TeacherAssignmentRow,
      PrefetchHooks Function()
    >;
typedef $StudentsCreateCompanionBuilder = StudentsCompanion Function({
  required String id,
  required String schoolId,
  required String lastName,
  required String firstNames,
  Value<String?> sex,
  Value<String?> birthDate,
  Value<String?> birthPlace,
  Value<String?> studentCode,
  Value<int?> registryNumber,
  Value<String?> registryProvisional,
  Value<String?> domicile,
  Value<String?> entryDate,
  Value<String?> exitDate,
  Value<String?> observations,
  Value<String?> photoPath,
  Value<String?> photoUpdatedAt,
  Value<String?> archivedAt,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $StudentsUpdateCompanionBuilder = StudentsCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> lastName,
  Value<String> firstNames,
  Value<String?> sex,
  Value<String?> birthDate,
  Value<String?> birthPlace,
  Value<String?> studentCode,
  Value<int?> registryNumber,
  Value<String?> registryProvisional,
  Value<String?> domicile,
  Value<String?> entryDate,
  Value<String?> exitDate,
  Value<String?> observations,
  Value<String?> photoPath,
  Value<String?> photoUpdatedAt,
  Value<String?> archivedAt,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $StudentsFilterComposer extends Composer<_$AppDatabase, Students> {
  $StudentsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstNames => $composableBuilder(
    column: $table.firstNames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentCode => $composableBuilder(
    column: $table.studentCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get registryNumber => $composableBuilder(
    column: $table.registryNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registryProvisional => $composableBuilder(
    column: $table.registryProvisional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domicile => $composableBuilder(
    column: $table.domicile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exitDate => $composableBuilder(
    column: $table.exitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUpdatedAt => $composableBuilder(
    column: $table.photoUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $StudentsOrderingComposer extends Composer<_$AppDatabase, Students> {
  $StudentsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstNames => $composableBuilder(
    column: $table.firstNames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentCode => $composableBuilder(
    column: $table.studentCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get registryNumber => $composableBuilder(
    column: $table.registryNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registryProvisional => $composableBuilder(
    column: $table.registryProvisional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domicile => $composableBuilder(
    column: $table.domicile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryDate => $composableBuilder(
    column: $table.entryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exitDate => $composableBuilder(
    column: $table.exitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUpdatedAt => $composableBuilder(
    column: $table.photoUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $StudentsAnnotationComposer extends Composer<_$AppDatabase, Students> {
  $StudentsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get firstNames => $composableBuilder(
    column: $table.firstNames,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get studentCode => $composableBuilder(
    column: $table.studentCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get registryNumber => $composableBuilder(
    column: $table.registryNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registryProvisional => $composableBuilder(
    column: $table.registryProvisional,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domicile =>
      $composableBuilder(column: $table.domicile, builder: (column) => column);

  GeneratedColumn<String> get entryDate =>
      $composableBuilder(column: $table.entryDate, builder: (column) => column);

  GeneratedColumn<String> get exitDate =>
      $composableBuilder(column: $table.exitDate, builder: (column) => column);

  GeneratedColumn<String> get observations => $composableBuilder(
    column: $table.observations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get photoUpdatedAt => $composableBuilder(
    column: $table.photoUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $StudentsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Students,
          StudentRow,
          $StudentsFilterComposer,
          $StudentsOrderingComposer,
          $StudentsAnnotationComposer,
          $StudentsCreateCompanionBuilder,
          $StudentsUpdateCompanionBuilder,
          (StudentRow, BaseReferences<_$AppDatabase, Students, StudentRow>),
          StudentRow,
          PrefetchHooks Function()
        > {
  $StudentsTableManager(_$AppDatabase db, Students table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $StudentsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $StudentsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $StudentsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> firstNames = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> studentCode = const Value.absent(),
                Value<int?> registryNumber = const Value.absent(),
                Value<String?> registryProvisional = const Value.absent(),
                Value<String?> domicile = const Value.absent(),
                Value<String?> entryDate = const Value.absent(),
                Value<String?> exitDate = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> photoUpdatedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                schoolId: schoolId,
                lastName: lastName,
                firstNames: firstNames,
                sex: sex,
                birthDate: birthDate,
                birthPlace: birthPlace,
                studentCode: studentCode,
                registryNumber: registryNumber,
                registryProvisional: registryProvisional,
                domicile: domicile,
                entryDate: entryDate,
                exitDate: exitDate,
                observations: observations,
                photoPath: photoPath,
                photoUpdatedAt: photoUpdatedAt,
                archivedAt: archivedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String lastName,
                required String firstNames,
                Value<String?> sex = const Value.absent(),
                Value<String?> birthDate = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> studentCode = const Value.absent(),
                Value<int?> registryNumber = const Value.absent(),
                Value<String?> registryProvisional = const Value.absent(),
                Value<String?> domicile = const Value.absent(),
                Value<String?> entryDate = const Value.absent(),
                Value<String?> exitDate = const Value.absent(),
                Value<String?> observations = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> photoUpdatedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                schoolId: schoolId,
                lastName: lastName,
                firstNames: firstNames,
                sex: sex,
                birthDate: birthDate,
                birthPlace: birthPlace,
                studentCode: studentCode,
                registryNumber: registryNumber,
                registryProvisional: registryProvisional,
                domicile: domicile,
                entryDate: entryDate,
                exitDate: exitDate,
                observations: observations,
                photoPath: photoPath,
                photoUpdatedAt: photoUpdatedAt,
                archivedAt: archivedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Students, StudentRow>(table),
                  BaseReferences<_$AppDatabase, Students, StudentRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $StudentsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Students,
      StudentRow,
      $StudentsFilterComposer,
      $StudentsOrderingComposer,
      $StudentsAnnotationComposer,
      $StudentsCreateCompanionBuilder,
      $StudentsUpdateCompanionBuilder,
      (StudentRow, BaseReferences<_$AppDatabase, Students, StudentRow>),
      StudentRow,
      PrefetchHooks Function()
    >;
typedef $StudentRegistryCreateCompanionBuilder =
    StudentRegistryCompanion Function({
      required String id,
      required String schoolId,
      Value<String?> originSchool,
      Value<String?> destination,
      Value<String?> exitReason,
      Value<String?> cepDate,
      Value<String?> diplomas,
      Value<String?> directorObservations,
      Value<String?> registryObservations,
      Value<String?> race,
      Value<String?> religion,
      Value<String?> createdAt,
      required String updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });
typedef $StudentRegistryUpdateCompanionBuilder =
    StudentRegistryCompanion Function({
      Value<String> id,
      Value<String> schoolId,
      Value<String?> originSchool,
      Value<String?> destination,
      Value<String?> exitReason,
      Value<String?> cepDate,
      Value<String?> diplomas,
      Value<String?> directorObservations,
      Value<String?> registryObservations,
      Value<String?> race,
      Value<String?> religion,
      Value<String?> createdAt,
      Value<String> updatedAt,
      Value<String?> deletedAt,
      Value<String?> syncedAt,
      Value<int> rowid,
    });

class $StudentRegistryFilterComposer
    extends Composer<_$AppDatabase, StudentRegistry> {
  $StudentRegistryFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originSchool => $composableBuilder(
    column: $table.originSchool,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exitReason => $composableBuilder(
    column: $table.exitReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cepDate => $composableBuilder(
    column: $table.cepDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diplomas => $composableBuilder(
    column: $table.diplomas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directorObservations => $composableBuilder(
    column: $table.directorObservations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registryObservations => $composableBuilder(
    column: $table.registryObservations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get race => $composableBuilder(
    column: $table.race,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get religion => $composableBuilder(
    column: $table.religion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $StudentRegistryOrderingComposer
    extends Composer<_$AppDatabase, StudentRegistry> {
  $StudentRegistryOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originSchool => $composableBuilder(
    column: $table.originSchool,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exitReason => $composableBuilder(
    column: $table.exitReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cepDate => $composableBuilder(
    column: $table.cepDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diplomas => $composableBuilder(
    column: $table.diplomas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directorObservations => $composableBuilder(
    column: $table.directorObservations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registryObservations => $composableBuilder(
    column: $table.registryObservations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get race => $composableBuilder(
    column: $table.race,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get religion => $composableBuilder(
    column: $table.religion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $StudentRegistryAnnotationComposer
    extends Composer<_$AppDatabase, StudentRegistry> {
  $StudentRegistryAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get originSchool => $composableBuilder(
    column: $table.originSchool,
    builder: (column) => column,
  );

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exitReason => $composableBuilder(
    column: $table.exitReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cepDate =>
      $composableBuilder(column: $table.cepDate, builder: (column) => column);

  GeneratedColumn<String> get diplomas =>
      $composableBuilder(column: $table.diplomas, builder: (column) => column);

  GeneratedColumn<String> get directorObservations => $composableBuilder(
    column: $table.directorObservations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registryObservations => $composableBuilder(
    column: $table.registryObservations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get race =>
      $composableBuilder(column: $table.race, builder: (column) => column);

  GeneratedColumn<String> get religion =>
      $composableBuilder(column: $table.religion, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $StudentRegistryTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          StudentRegistry,
          StudentRegistryRow,
          $StudentRegistryFilterComposer,
          $StudentRegistryOrderingComposer,
          $StudentRegistryAnnotationComposer,
          $StudentRegistryCreateCompanionBuilder,
          $StudentRegistryUpdateCompanionBuilder,
          (
            StudentRegistryRow,
            BaseReferences<_$AppDatabase, StudentRegistry, StudentRegistryRow>,
          ),
          StudentRegistryRow,
          PrefetchHooks Function()
        > {
  $StudentRegistryTableManager(_$AppDatabase db, StudentRegistry table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $StudentRegistryFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $StudentRegistryOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $StudentRegistryAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String?> originSchool = const Value.absent(),
                Value<String?> destination = const Value.absent(),
                Value<String?> exitReason = const Value.absent(),
                Value<String?> cepDate = const Value.absent(),
                Value<String?> diplomas = const Value.absent(),
                Value<String?> directorObservations = const Value.absent(),
                Value<String?> registryObservations = const Value.absent(),
                Value<String?> race = const Value.absent(),
                Value<String?> religion = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentRegistryCompanion(
                id: id,
                schoolId: schoolId,
                originSchool: originSchool,
                destination: destination,
                exitReason: exitReason,
                cepDate: cepDate,
                diplomas: diplomas,
                directorObservations: directorObservations,
                registryObservations: registryObservations,
                race: race,
                religion: religion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                Value<String?> originSchool = const Value.absent(),
                Value<String?> destination = const Value.absent(),
                Value<String?> exitReason = const Value.absent(),
                Value<String?> cepDate = const Value.absent(),
                Value<String?> diplomas = const Value.absent(),
                Value<String?> directorObservations = const Value.absent(),
                Value<String?> registryObservations = const Value.absent(),
                Value<String?> race = const Value.absent(),
                Value<String?> religion = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentRegistryCompanion.insert(
                id: id,
                schoolId: schoolId,
                originSchool: originSchool,
                destination: destination,
                exitReason: exitReason,
                cepDate: cepDate,
                diplomas: diplomas,
                directorObservations: directorObservations,
                registryObservations: registryObservations,
                race: race,
                religion: religion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<StudentRegistry, StudentRegistryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    StudentRegistry,
                    StudentRegistryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $StudentRegistryProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      StudentRegistry,
      StudentRegistryRow,
      $StudentRegistryFilterComposer,
      $StudentRegistryOrderingComposer,
      $StudentRegistryAnnotationComposer,
      $StudentRegistryCreateCompanionBuilder,
      $StudentRegistryUpdateCompanionBuilder,
      (
        StudentRegistryRow,
        BaseReferences<_$AppDatabase, StudentRegistry, StudentRegistryRow>,
      ),
      StudentRegistryRow,
      PrefetchHooks Function()
    >;
typedef $GuardiansCreateCompanionBuilder = GuardiansCompanion Function({
  required String id,
  required String schoolId,
  required String studentId,
  required String relation,
  required String fullName,
  Value<String?> profession,
  Value<String?> domicile,
  Value<String?> address,
  Value<String?> phone,
  Value<bool> isLodger,
  Value<int> sortOrder,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $GuardiansUpdateCompanionBuilder = GuardiansCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> studentId,
  Value<String> relation,
  Value<String> fullName,
  Value<String?> profession,
  Value<String?> domicile,
  Value<String?> address,
  Value<String?> phone,
  Value<bool> isLodger,
  Value<int> sortOrder,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $GuardiansFilterComposer extends Composer<_$AppDatabase, Guardians> {
  $GuardiansFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profession => $composableBuilder(
    column: $table.profession,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domicile => $composableBuilder(
    column: $table.domicile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLodger => $composableBuilder(
    column: $table.isLodger,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $GuardiansOrderingComposer extends Composer<_$AppDatabase, Guardians> {
  $GuardiansOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profession => $composableBuilder(
    column: $table.profession,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domicile => $composableBuilder(
    column: $table.domicile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLodger => $composableBuilder(
    column: $table.isLodger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $GuardiansAnnotationComposer extends Composer<_$AppDatabase, Guardians> {
  $GuardiansAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get profession => $composableBuilder(
    column: $table.profession,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domicile =>
      $composableBuilder(column: $table.domicile, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isLodger =>
      $composableBuilder(column: $table.isLodger, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $GuardiansTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Guardians,
          GuardianRow,
          $GuardiansFilterComposer,
          $GuardiansOrderingComposer,
          $GuardiansAnnotationComposer,
          $GuardiansCreateCompanionBuilder,
          $GuardiansUpdateCompanionBuilder,
          (GuardianRow, BaseReferences<_$AppDatabase, Guardians, GuardianRow>),
          GuardianRow,
          PrefetchHooks Function()
        > {
  $GuardiansTableManager(_$AppDatabase db, Guardians table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $GuardiansFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $GuardiansOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $GuardiansAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> profession = const Value.absent(),
                Value<String?> domicile = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isLodger = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuardiansCompanion(
                id: id,
                schoolId: schoolId,
                studentId: studentId,
                relation: relation,
                fullName: fullName,
                profession: profession,
                domicile: domicile,
                address: address,
                phone: phone,
                isLodger: isLodger,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String studentId,
                required String relation,
                required String fullName,
                Value<String?> profession = const Value.absent(),
                Value<String?> domicile = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isLodger = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuardiansCompanion.insert(
                id: id,
                schoolId: schoolId,
                studentId: studentId,
                relation: relation,
                fullName: fullName,
                profession: profession,
                domicile: domicile,
                address: address,
                phone: phone,
                isLodger: isLodger,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Guardians, GuardianRow>(table),
                  BaseReferences<_$AppDatabase, Guardians, GuardianRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $GuardiansProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Guardians,
      GuardianRow,
      $GuardiansFilterComposer,
      $GuardiansOrderingComposer,
      $GuardiansAnnotationComposer,
      $GuardiansCreateCompanionBuilder,
      $GuardiansUpdateCompanionBuilder,
      (GuardianRow, BaseReferences<_$AppDatabase, Guardians, GuardianRow>),
      GuardianRow,
      PrefetchHooks Function()
    >;
typedef $EnrollmentsCreateCompanionBuilder = EnrollmentsCompanion Function({
  required String id,
  required String schoolId,
  required String studentId,
  required String classId,
  required String schoolYearId,
  required String levelCode,
  Value<String?> startsOn,
  Value<String?> endsOn,
  Value<String?> endReason,
  Value<bool> isRepeat,
  Value<String?> createdAt,
  required String updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});
typedef $EnrollmentsUpdateCompanionBuilder = EnrollmentsCompanion Function({
  Value<String> id,
  Value<String> schoolId,
  Value<String> studentId,
  Value<String> classId,
  Value<String> schoolYearId,
  Value<String> levelCode,
  Value<String?> startsOn,
  Value<String?> endsOn,
  Value<String?> endReason,
  Value<bool> isRepeat,
  Value<String?> createdAt,
  Value<String> updatedAt,
  Value<String?> deletedAt,
  Value<String?> syncedAt,
  Value<int> rowid,
});

class $EnrollmentsFilterComposer extends Composer<_$AppDatabase, Enrollments> {
  $EnrollmentsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelCode => $composableBuilder(
    column: $table.levelCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endReason => $composableBuilder(
    column: $table.endReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRepeat => $composableBuilder(
    column: $table.isRepeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $EnrollmentsOrderingComposer
    extends Composer<_$AppDatabase, Enrollments> {
  $EnrollmentsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelCode => $composableBuilder(
    column: $table.levelCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endReason => $composableBuilder(
    column: $table.endReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRepeat => $composableBuilder(
    column: $table.isRepeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $EnrollmentsAnnotationComposer
    extends Composer<_$AppDatabase, Enrollments> {
  $EnrollmentsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get schoolYearId => $composableBuilder(
    column: $table.schoolYearId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get levelCode =>
      $composableBuilder(column: $table.levelCode, builder: (column) => column);

  GeneratedColumn<String> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<String> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<String> get endReason =>
      $composableBuilder(column: $table.endReason, builder: (column) => column);

  GeneratedColumn<bool> get isRepeat =>
      $composableBuilder(column: $table.isRepeat, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $EnrollmentsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Enrollments,
          EnrollmentRow,
          $EnrollmentsFilterComposer,
          $EnrollmentsOrderingComposer,
          $EnrollmentsAnnotationComposer,
          $EnrollmentsCreateCompanionBuilder,
          $EnrollmentsUpdateCompanionBuilder,
          (
            EnrollmentRow,
            BaseReferences<_$AppDatabase, Enrollments, EnrollmentRow>,
          ),
          EnrollmentRow,
          PrefetchHooks Function()
        > {
  $EnrollmentsTableManager(_$AppDatabase db, Enrollments table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $EnrollmentsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $EnrollmentsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $EnrollmentsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> schoolYearId = const Value.absent(),
                Value<String> levelCode = const Value.absent(),
                Value<String?> startsOn = const Value.absent(),
                Value<String?> endsOn = const Value.absent(),
                Value<String?> endReason = const Value.absent(),
                Value<bool> isRepeat = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnrollmentsCompanion(
                id: id,
                schoolId: schoolId,
                studentId: studentId,
                classId: classId,
                schoolYearId: schoolYearId,
                levelCode: levelCode,
                startsOn: startsOn,
                endsOn: endsOn,
                endReason: endReason,
                isRepeat: isRepeat,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String schoolId,
                required String studentId,
                required String classId,
                required String schoolYearId,
                required String levelCode,
                Value<String?> startsOn = const Value.absent(),
                Value<String?> endsOn = const Value.absent(),
                Value<String?> endReason = const Value.absent(),
                Value<bool> isRepeat = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                required String updatedAt,
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnrollmentsCompanion.insert(
                id: id,
                schoolId: schoolId,
                studentId: studentId,
                classId: classId,
                schoolYearId: schoolYearId,
                levelCode: levelCode,
                startsOn: startsOn,
                endsOn: endsOn,
                endReason: endReason,
                isRepeat: isRepeat,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Enrollments, EnrollmentRow>(table),
                  BaseReferences<_$AppDatabase, Enrollments, EnrollmentRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $EnrollmentsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Enrollments,
      EnrollmentRow,
      $EnrollmentsFilterComposer,
      $EnrollmentsOrderingComposer,
      $EnrollmentsAnnotationComposer,
      $EnrollmentsCreateCompanionBuilder,
      $EnrollmentsUpdateCompanionBuilder,
      (
        EnrollmentRow,
        BaseReferences<_$AppDatabase, Enrollments, EnrollmentRow>,
      ),
      EnrollmentRow,
      PrefetchHooks Function()
    >;
typedef $OutboxCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  required String targetTable,
  required String rowKey,
  required String payload,
  Value<int> revision,
  Value<String> status,
  Value<String?> message,
  Value<int> attempts,
  required String createdAt,
});
typedef $OutboxUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> id,
  Value<String> targetTable,
  Value<String> rowKey,
  Value<String> payload,
  Value<int> revision,
  Value<String> status,
  Value<String?> message,
  Value<int> attempts,
  Value<String> createdAt,
});

class $OutboxFilterComposer extends Composer<_$AppDatabase, Outbox> {
  $OutboxFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowKey => $composableBuilder(
    column: $table.rowKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $OutboxOrderingComposer extends Composer<_$AppDatabase, Outbox> {
  $OutboxOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowKey => $composableBuilder(
    column: $table.rowKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $OutboxAnnotationComposer extends Composer<_$AppDatabase, Outbox> {
  $OutboxAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rowKey =>
      $composableBuilder(column: $table.rowKey, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $OutboxTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Outbox,
          OutboxEntry,
          $OutboxFilterComposer,
          $OutboxOrderingComposer,
          $OutboxAnnotationComposer,
          $OutboxCreateCompanionBuilder,
          $OutboxUpdateCompanionBuilder,
          (OutboxEntry, BaseReferences<_$AppDatabase, Outbox, OutboxEntry>),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $OutboxTableManager(_$AppDatabase db, Outbox table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $OutboxFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $OutboxOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $OutboxAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> rowKey = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => OutboxCompanion(
                id: id,
                targetTable: targetTable,
                rowKey: rowKey,
                payload: payload,
                revision: revision,
                status: status,
                message: message,
                attempts: attempts,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetTable,
                required String rowKey,
                required String payload,
                Value<int> revision = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                required String createdAt,
              }) => OutboxCompanion.insert(
                id: id,
                targetTable: targetTable,
                rowKey: rowKey,
                payload: payload,
                revision: revision,
                status: status,
                message: message,
                attempts: attempts,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Outbox, OutboxEntry>(table),
                  BaseReferences<_$AppDatabase, Outbox, OutboxEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $OutboxProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Outbox,
      OutboxEntry,
      $OutboxFilterComposer,
      $OutboxOrderingComposer,
      $OutboxAnnotationComposer,
      $OutboxCreateCompanionBuilder,
      $OutboxUpdateCompanionBuilder,
      (OutboxEntry, BaseReferences<_$AppDatabase, Outbox, OutboxEntry>),
      OutboxEntry,
      PrefetchHooks Function()
    >;
typedef $SyncCursorsCreateCompanionBuilder = SyncCursorsCompanion Function({
  required String targetTable,
  required String syncedAt,
  Value<String> tie,
  Value<int> rowid,
});
typedef $SyncCursorsUpdateCompanionBuilder = SyncCursorsCompanion Function({
  Value<String> targetTable,
  Value<String> syncedAt,
  Value<String> tie,
  Value<int> rowid,
});

class $SyncCursorsFilterComposer extends Composer<_$AppDatabase, SyncCursors> {
  $SyncCursorsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tie => $composableBuilder(
    column: $table.tie,
    builder: (column) => ColumnFilters(column),
  );
}

class $SyncCursorsOrderingComposer
    extends Composer<_$AppDatabase, SyncCursors> {
  $SyncCursorsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tie => $composableBuilder(
    column: $table.tie,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SyncCursorsAnnotationComposer
    extends Composer<_$AppDatabase, SyncCursors> {
  $SyncCursorsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<String> get tie =>
      $composableBuilder(column: $table.tie, builder: (column) => column);
}

class $SyncCursorsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SyncCursors,
          SyncCursor,
          $SyncCursorsFilterComposer,
          $SyncCursorsOrderingComposer,
          $SyncCursorsAnnotationComposer,
          $SyncCursorsCreateCompanionBuilder,
          $SyncCursorsUpdateCompanionBuilder,
          (SyncCursor, BaseReferences<_$AppDatabase, SyncCursors, SyncCursor>),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $SyncCursorsTableManager(_$AppDatabase db, SyncCursors table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SyncCursorsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SyncCursorsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SyncCursorsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> targetTable = const Value.absent(),
                Value<String> syncedAt = const Value.absent(),
                Value<String> tie = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                targetTable: targetTable,
                syncedAt: syncedAt,
                tie: tie,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String targetTable,
                required String syncedAt,
                Value<String> tie = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                targetTable: targetTable,
                syncedAt: syncedAt,
                tie: tie,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SyncCursors, SyncCursor>(table),
                  BaseReferences<_$AppDatabase, SyncCursors, SyncCursor>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SyncCursorsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SyncCursors,
      SyncCursor,
      $SyncCursorsFilterComposer,
      $SyncCursorsOrderingComposer,
      $SyncCursorsAnnotationComposer,
      $SyncCursorsCreateCompanionBuilder,
      $SyncCursorsUpdateCompanionBuilder,
      (SyncCursor, BaseReferences<_$AppDatabase, SyncCursors, SyncCursor>),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $LocalSessionCreateCompanionBuilder = LocalSessionCompanion Function({
  Value<int> id,
  required String userId,
  required String login,
  required String membershipId,
  required String schoolId,
  required String role,
  required String displayName,
  required String deviceId,
  Value<String?> deviceSeries,
  Value<int> clockOffsetMs,
  Value<String?> lastSyncAt,
  Value<String?> journalSeenAt,
});
typedef $LocalSessionUpdateCompanionBuilder = LocalSessionCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> login,
  Value<String> membershipId,
  Value<String> schoolId,
  Value<String> role,
  Value<String> displayName,
  Value<String> deviceId,
  Value<String?> deviceSeries,
  Value<int> clockOffsetMs,
  Value<String?> lastSyncAt,
  Value<String?> journalSeenAt,
});

class $LocalSessionFilterComposer
    extends Composer<_$AppDatabase, LocalSession> {
  $LocalSessionFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceSeries => $composableBuilder(
    column: $table.deviceSeries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clockOffsetMs => $composableBuilder(
    column: $table.clockOffsetMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get journalSeenAt => $composableBuilder(
    column: $table.journalSeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $LocalSessionOrderingComposer
    extends Composer<_$AppDatabase, LocalSession> {
  $LocalSessionOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get login => $composableBuilder(
    column: $table.login,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceSeries => $composableBuilder(
    column: $table.deviceSeries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clockOffsetMs => $composableBuilder(
    column: $table.clockOffsetMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get journalSeenAt => $composableBuilder(
    column: $table.journalSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $LocalSessionAnnotationComposer
    extends Composer<_$AppDatabase, LocalSession> {
  $LocalSessionAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get login =>
      $composableBuilder(column: $table.login, builder: (column) => column);

  GeneratedColumn<String> get membershipId => $composableBuilder(
    column: $table.membershipId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceSeries => $composableBuilder(
    column: $table.deviceSeries,
    builder: (column) => column,
  );

  GeneratedColumn<int> get clockOffsetMs => $composableBuilder(
    column: $table.clockOffsetMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get journalSeenAt => $composableBuilder(
    column: $table.journalSeenAt,
    builder: (column) => column,
  );
}

class $LocalSessionTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LocalSession,
          LocalSessionRow,
          $LocalSessionFilterComposer,
          $LocalSessionOrderingComposer,
          $LocalSessionAnnotationComposer,
          $LocalSessionCreateCompanionBuilder,
          $LocalSessionUpdateCompanionBuilder,
          (
            LocalSessionRow,
            BaseReferences<_$AppDatabase, LocalSession, LocalSessionRow>,
          ),
          LocalSessionRow,
          PrefetchHooks Function()
        > {
  $LocalSessionTableManager(_$AppDatabase db, LocalSession table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LocalSessionFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LocalSessionOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LocalSessionAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> login = const Value.absent(),
                Value<String> membershipId = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> deviceSeries = const Value.absent(),
                Value<int> clockOffsetMs = const Value.absent(),
                Value<String?> lastSyncAt = const Value.absent(),
                Value<String?> journalSeenAt = const Value.absent(),
              }) => LocalSessionCompanion(
                id: id,
                userId: userId,
                login: login,
                membershipId: membershipId,
                schoolId: schoolId,
                role: role,
                displayName: displayName,
                deviceId: deviceId,
                deviceSeries: deviceSeries,
                clockOffsetMs: clockOffsetMs,
                lastSyncAt: lastSyncAt,
                journalSeenAt: journalSeenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String login,
                required String membershipId,
                required String schoolId,
                required String role,
                required String displayName,
                required String deviceId,
                Value<String?> deviceSeries = const Value.absent(),
                Value<int> clockOffsetMs = const Value.absent(),
                Value<String?> lastSyncAt = const Value.absent(),
                Value<String?> journalSeenAt = const Value.absent(),
              }) => LocalSessionCompanion.insert(
                id: id,
                userId: userId,
                login: login,
                membershipId: membershipId,
                schoolId: schoolId,
                role: role,
                displayName: displayName,
                deviceId: deviceId,
                deviceSeries: deviceSeries,
                clockOffsetMs: clockOffsetMs,
                lastSyncAt: lastSyncAt,
                journalSeenAt: journalSeenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LocalSession, LocalSessionRow>(table),
                  BaseReferences<_$AppDatabase, LocalSession, LocalSessionRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $LocalSessionProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LocalSession,
      LocalSessionRow,
      $LocalSessionFilterComposer,
      $LocalSessionOrderingComposer,
      $LocalSessionAnnotationComposer,
      $LocalSessionCreateCompanionBuilder,
      $LocalSessionUpdateCompanionBuilder,
      (
        LocalSessionRow,
        BaseReferences<_$AppDatabase, LocalSession, LocalSessionRow>,
      ),
      LocalSessionRow,
      PrefetchHooks Function()
    >;
typedef $DraftsCreateCompanionBuilder = DraftsCompanion Function({
  required String key,
  required String payload,
  required String updatedAt,
  Value<int> rowid,
});
typedef $DraftsUpdateCompanionBuilder = DraftsCompanion Function({
  Value<String> key,
  Value<String> payload,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $DraftsFilterComposer extends Composer<_$AppDatabase, Drafts> {
  $DraftsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $DraftsOrderingComposer extends Composer<_$AppDatabase, Drafts> {
  $DraftsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DraftsAnnotationComposer extends Composer<_$AppDatabase, Drafts> {
  $DraftsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $DraftsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Drafts,
          DraftRow,
          $DraftsFilterComposer,
          $DraftsOrderingComposer,
          $DraftsAnnotationComposer,
          $DraftsCreateCompanionBuilder,
          $DraftsUpdateCompanionBuilder,
          (DraftRow, BaseReferences<_$AppDatabase, Drafts, DraftRow>),
          DraftRow,
          PrefetchHooks Function()
        > {
  $DraftsTableManager(_$AppDatabase db, Drafts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DraftsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DraftsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DraftsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion(
                key: key,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String payload,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DraftsCompanion.insert(
                key: key,
                payload: payload,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Drafts, DraftRow>(table),
                  BaseReferences<_$AppDatabase, Drafts, DraftRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DraftsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Drafts,
      DraftRow,
      $DraftsFilterComposer,
      $DraftsOrderingComposer,
      $DraftsAnnotationComposer,
      $DraftsCreateCompanionBuilder,
      $DraftsUpdateCompanionBuilder,
      (DraftRow, BaseReferences<_$AppDatabase, Drafts, DraftRow>),
      DraftRow,
      PrefetchHooks Function()
    >;
typedef $FileUploadsCreateCompanionBuilder = FileUploadsCompanion Function({
  Value<int> id,
  required String localPath,
  required String bucket,
  required String objectPath,
  required String contentType,
  Value<int> attempts,
  required String createdAt,
});
typedef $FileUploadsUpdateCompanionBuilder = FileUploadsCompanion Function({
  Value<int> id,
  Value<String> localPath,
  Value<String> bucket,
  Value<String> objectPath,
  Value<String> contentType,
  Value<int> attempts,
  Value<String> createdAt,
});

class $FileUploadsFilterComposer extends Composer<_$AppDatabase, FileUploads> {
  $FileUploadsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get objectPath => $composableBuilder(
    column: $table.objectPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $FileUploadsOrderingComposer
    extends Composer<_$AppDatabase, FileUploads> {
  $FileUploadsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectPath => $composableBuilder(
    column: $table.objectPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $FileUploadsAnnotationComposer
    extends Composer<_$AppDatabase, FileUploads> {
  $FileUploadsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<String> get objectPath => $composableBuilder(
    column: $table.objectPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $FileUploadsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          FileUploads,
          FileUploadRow,
          $FileUploadsFilterComposer,
          $FileUploadsOrderingComposer,
          $FileUploadsAnnotationComposer,
          $FileUploadsCreateCompanionBuilder,
          $FileUploadsUpdateCompanionBuilder,
          (
            FileUploadRow,
            BaseReferences<_$AppDatabase, FileUploads, FileUploadRow>,
          ),
          FileUploadRow,
          PrefetchHooks Function()
        > {
  $FileUploadsTableManager(_$AppDatabase db, FileUploads table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FileUploadsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FileUploadsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FileUploadsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> bucket = const Value.absent(),
                Value<String> objectPath = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => FileUploadsCompanion(
                id: id,
                localPath: localPath,
                bucket: bucket,
                objectPath: objectPath,
                contentType: contentType,
                attempts: attempts,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String localPath,
                required String bucket,
                required String objectPath,
                required String contentType,
                Value<int> attempts = const Value.absent(),
                required String createdAt,
              }) => FileUploadsCompanion.insert(
                id: id,
                localPath: localPath,
                bucket: bucket,
                objectPath: objectPath,
                contentType: contentType,
                attempts: attempts,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<FileUploads, FileUploadRow>(table),
                  BaseReferences<_$AppDatabase, FileUploads, FileUploadRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $FileUploadsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      FileUploads,
      FileUploadRow,
      $FileUploadsFilterComposer,
      $FileUploadsOrderingComposer,
      $FileUploadsAnnotationComposer,
      $FileUploadsCreateCompanionBuilder,
      $FileUploadsUpdateCompanionBuilder,
      (
        FileUploadRow,
        BaseReferences<_$AppDatabase, FileUploads, FileUploadRow>,
      ),
      FileUploadRow,
      PrefetchHooks Function()
    >;
typedef $DeviceIdentityCreateCompanionBuilder =
    DeviceIdentityCompanion Function({
      Value<int> id,
      required String deviceId,
      Value<String?> notice,
    });
typedef $DeviceIdentityUpdateCompanionBuilder =
    DeviceIdentityCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<String?> notice,
    });

class $DeviceIdentityFilterComposer
    extends Composer<_$AppDatabase, DeviceIdentity> {
  $DeviceIdentityFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notice => $composableBuilder(
    column: $table.notice,
    builder: (column) => ColumnFilters(column),
  );
}

class $DeviceIdentityOrderingComposer
    extends Composer<_$AppDatabase, DeviceIdentity> {
  $DeviceIdentityOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notice => $composableBuilder(
    column: $table.notice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DeviceIdentityAnnotationComposer
    extends Composer<_$AppDatabase, DeviceIdentity> {
  $DeviceIdentityAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get notice =>
      $composableBuilder(column: $table.notice, builder: (column) => column);
}

class $DeviceIdentityTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          DeviceIdentity,
          DeviceIdentityRow,
          $DeviceIdentityFilterComposer,
          $DeviceIdentityOrderingComposer,
          $DeviceIdentityAnnotationComposer,
          $DeviceIdentityCreateCompanionBuilder,
          $DeviceIdentityUpdateCompanionBuilder,
          (
            DeviceIdentityRow,
            BaseReferences<_$AppDatabase, DeviceIdentity, DeviceIdentityRow>,
          ),
          DeviceIdentityRow,
          PrefetchHooks Function()
        > {
  $DeviceIdentityTableManager(_$AppDatabase db, DeviceIdentity table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DeviceIdentityFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DeviceIdentityOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DeviceIdentityAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String?> notice = const Value.absent(),
              }) => DeviceIdentityCompanion(
                id: id,
                deviceId: deviceId,
                notice: notice,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                Value<String?> notice = const Value.absent(),
              }) => DeviceIdentityCompanion.insert(
                id: id,
                deviceId: deviceId,
                notice: notice,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<DeviceIdentity, DeviceIdentityRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    DeviceIdentity,
                    DeviceIdentityRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DeviceIdentityProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      DeviceIdentity,
      DeviceIdentityRow,
      $DeviceIdentityFilterComposer,
      $DeviceIdentityOrderingComposer,
      $DeviceIdentityAnnotationComposer,
      $DeviceIdentityCreateCompanionBuilder,
      $DeviceIdentityUpdateCompanionBuilder,
      (
        DeviceIdentityRow,
        BaseReferences<_$AppDatabase, DeviceIdentity, DeviceIdentityRow>,
      ),
      DeviceIdentityRow,
      PrefetchHooks Function()
    >;
typedef $AppLockCreateCompanionBuilder = AppLockCompanion Function({
  Value<int> id,
  required String pinHash,
  required String pinSalt,
  required int iterations,
  Value<bool> biometric,
  Value<int> failedAttempts,
  Value<String?> blockedUntil,
});
typedef $AppLockUpdateCompanionBuilder = AppLockCompanion Function({
  Value<int> id,
  Value<String> pinHash,
  Value<String> pinSalt,
  Value<int> iterations,
  Value<bool> biometric,
  Value<int> failedAttempts,
  Value<String?> blockedUntil,
});

class $AppLockFilterComposer extends Composer<_$AppDatabase, AppLock> {
  $AppLockFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get biometric => $composableBuilder(
    column: $table.biometric,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blockedUntil => $composableBuilder(
    column: $table.blockedUntil,
    builder: (column) => ColumnFilters(column),
  );
}

class $AppLockOrderingComposer extends Composer<_$AppDatabase, AppLock> {
  $AppLockOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinHash => $composableBuilder(
    column: $table.pinHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinSalt => $composableBuilder(
    column: $table.pinSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get biometric => $composableBuilder(
    column: $table.biometric,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockedUntil => $composableBuilder(
    column: $table.blockedUntil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AppLockAnnotationComposer extends Composer<_$AppDatabase, AppLock> {
  $AppLockAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pinHash =>
      $composableBuilder(column: $table.pinHash, builder: (column) => column);

  GeneratedColumn<String> get pinSalt =>
      $composableBuilder(column: $table.pinSalt, builder: (column) => column);

  GeneratedColumn<int> get iterations => $composableBuilder(
    column: $table.iterations,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get biometric =>
      $composableBuilder(column: $table.biometric, builder: (column) => column);

  GeneratedColumn<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get blockedUntil => $composableBuilder(
    column: $table.blockedUntil,
    builder: (column) => column,
  );
}

class $AppLockTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          AppLock,
          AppLockRow,
          $AppLockFilterComposer,
          $AppLockOrderingComposer,
          $AppLockAnnotationComposer,
          $AppLockCreateCompanionBuilder,
          $AppLockUpdateCompanionBuilder,
          (AppLockRow, BaseReferences<_$AppDatabase, AppLock, AppLockRow>),
          AppLockRow,
          PrefetchHooks Function()
        > {
  $AppLockTableManager(_$AppDatabase db, AppLock table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AppLockFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AppLockOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AppLockAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pinHash = const Value.absent(),
                Value<String> pinSalt = const Value.absent(),
                Value<int> iterations = const Value.absent(),
                Value<bool> biometric = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<String?> blockedUntil = const Value.absent(),
              }) => AppLockCompanion(
                id: id,
                pinHash: pinHash,
                pinSalt: pinSalt,
                iterations: iterations,
                biometric: biometric,
                failedAttempts: failedAttempts,
                blockedUntil: blockedUntil,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pinHash,
                required String pinSalt,
                required int iterations,
                Value<bool> biometric = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<String?> blockedUntil = const Value.absent(),
              }) => AppLockCompanion.insert(
                id: id,
                pinHash: pinHash,
                pinSalt: pinSalt,
                iterations: iterations,
                biometric: biometric,
                failedAttempts: failedAttempts,
                blockedUntil: blockedUntil,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<AppLock, AppLockRow>(table),
                  BaseReferences<_$AppDatabase, AppLock, AppLockRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AppLockProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      AppLock,
      AppLockRow,
      $AppLockFilterComposer,
      $AppLockOrderingComposer,
      $AppLockAnnotationComposer,
      $AppLockCreateCompanionBuilder,
      $AppLockUpdateCompanionBuilder,
      (AppLockRow, BaseReferences<_$AppDatabase, AppLock, AppLockRow>),
      AppLockRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $SchoolsTableManager get schools => $SchoolsTableManager(_db, _db.schools);
  $SchoolYearsTableManager get schoolYears =>
      $SchoolYearsTableManager(_db, _db.schoolYears);
  $AdminHeadersTableManager get adminHeaders =>
      $AdminHeadersTableManager(_db, _db.adminHeaders);
  $ModulesCatalogTableManager get modulesCatalog =>
      $ModulesCatalogTableManager(_db, _db.modulesCatalog);
  $SchoolModulesTableManager get schoolModules =>
      $SchoolModulesTableManager(_db, _db.schoolModules);
  $MembershipsTableManager get memberships =>
      $MembershipsTableManager(_db, _db.memberships);
  $DelegatePermissionsTableManager get delegatePermissions =>
      $DelegatePermissionsTableManager(_db, _db.delegatePermissions);
  $DevicesTableManager get devices => $DevicesTableManager(_db, _db.devices);
  $AuditLogTableManager get auditLog =>
      $AuditLogTableManager(_db, _db.auditLog);
  $LevelsTableManager get levels => $LevelsTableManager(_db, _db.levels);
  $TeachersTableManager get teachers =>
      $TeachersTableManager(_db, _db.teachers);
  $TeacherPostingsTableManager get teacherPostings =>
      $TeacherPostingsTableManager(_db, _db.teacherPostings);
  $TeacherInterruptionsTableManager get teacherInterruptions =>
      $TeacherInterruptionsTableManager(_db, _db.teacherInterruptions);
  $TeacherAwardsTableManager get teacherAwards =>
      $TeacherAwardsTableManager(_db, _db.teacherAwards);
  $TeacherDiplomasTableManager get teacherDiplomas =>
      $TeacherDiplomasTableManager(_db, _db.teacherDiplomas);
  $ClassesTableManager get classes => $ClassesTableManager(_db, _db.classes);
  $TeacherYearAssignmentsTableManager get teacherYearAssignments =>
      $TeacherYearAssignmentsTableManager(_db, _db.teacherYearAssignments);
  $StudentsTableManager get students =>
      $StudentsTableManager(_db, _db.students);
  $StudentRegistryTableManager get studentRegistry =>
      $StudentRegistryTableManager(_db, _db.studentRegistry);
  $GuardiansTableManager get guardians =>
      $GuardiansTableManager(_db, _db.guardians);
  $EnrollmentsTableManager get enrollments =>
      $EnrollmentsTableManager(_db, _db.enrollments);
  $OutboxTableManager get outbox => $OutboxTableManager(_db, _db.outbox);
  $SyncCursorsTableManager get syncCursors =>
      $SyncCursorsTableManager(_db, _db.syncCursors);
  $LocalSessionTableManager get localSession =>
      $LocalSessionTableManager(_db, _db.localSession);
  $DraftsTableManager get drafts => $DraftsTableManager(_db, _db.drafts);
  $FileUploadsTableManager get fileUploads =>
      $FileUploadsTableManager(_db, _db.fileUploads);
  $DeviceIdentityTableManager get deviceIdentity =>
      $DeviceIdentityTableManager(_db, _db.deviceIdentity);
  $AppLockTableManager get appLock => $AppLockTableManager(_db, _db.appLock);
}
