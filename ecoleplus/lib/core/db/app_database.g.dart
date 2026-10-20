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
          ..write('lastSyncAt: $lastSyncAt')
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
          other.lastSyncAt == this.lastSyncAt);
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
          ..write('lastSyncAt: $lastSyncAt')
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
  @override
  List<GeneratedColumn> get $columns => [id, deviceId];
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
  const DeviceIdentityRow({required this.id, required this.deviceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  DeviceIdentityCompanion toCompanion(bool nullToAbsent) {
    return DeviceIdentityCompanion(id: Value(id), deviceId: Value(deviceId));
  }

  factory DeviceIdentityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceIdentityRow(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['device_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'device_id': serializer.toJson<String>(deviceId),
    };
  }

  DeviceIdentityRow copyWith({int? id, String? deviceId}) =>
      DeviceIdentityRow(id: id ?? this.id, deviceId: deviceId ?? this.deviceId);
  DeviceIdentityRow copyWithCompanion(DeviceIdentityCompanion data) {
    return DeviceIdentityRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIdentityRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceIdentityRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId);
}

class DeviceIdentityCompanion extends UpdateCompanion<DeviceIdentityRow> {
  final Value<int> id;
  final Value<String> deviceId;
  const DeviceIdentityCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
  });
  DeviceIdentityCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
  }) : deviceId = Value(deviceId);
  static Insertable<DeviceIdentityRow> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
    });
  }

  DeviceIdentityCompanion copyWith({Value<int>? id, Value<String>? deviceId}) {
    return DeviceIdentityCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceIdentityCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId')
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
  late final Outbox outbox = Outbox(this);
  late final SyncCursors syncCursors = SyncCursors(this);
  late final LocalSession localSession = LocalSession(this);
  late final Drafts drafts = Drafts(this);
  late final FileUploads fileUploads = FileUploads(this);
  late final DeviceIdentity deviceIdentity = DeviceIdentity(this);
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
    outbox,
    syncCursors,
    localSession,
    drafts,
    fileUploads,
    deviceIdentity,
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
    DeviceIdentityCompanion Function({Value<int> id, required String deviceId});
typedef $DeviceIdentityUpdateCompanionBuilder =
    DeviceIdentityCompanion Function({Value<int> id, Value<String> deviceId});

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
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
          }) => DeviceIdentityCompanion(id: id, deviceId: deviceId),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String deviceId,
          }) => DeviceIdentityCompanion.insert(id: id, deviceId: deviceId),
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
}
