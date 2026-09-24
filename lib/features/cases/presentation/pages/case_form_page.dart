import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_date_field.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../courts/domain/entities/case_type_reference.dart';
import '../../domain/entities/court.dart';
import '../../data/models/create_case_request.dart';
import '../../data/models/update_case_request.dart';
import '../../domain/entities/case_priority.dart';
import '../../domain/entities/case_status.dart';
import '../../domain/entities/legal_case.dart';
import '../bloc/case_form_bloc.dart';
import '../case_display_helpers.dart';

/// Shared Create/Edit screen — `existingCase == null` means create mode.
/// `caseNumber`/`clientId`/`caseTypeId` are only ever set on create; the
/// edit form redisplays them read-only (`caseTypeId` resolved to a label
/// via the loaded case-type Lookups, same list the create-mode dropdown
/// uses). No primary-lawyer field anywhere — removed from the backend
/// schema entirely (API_CONTRACT.md finding N); team membership is a
/// separate action on `CaseDetailsPage`.
class CaseFormPage extends StatelessWidget {
  final LegalCase? existingCase;

  const CaseFormPage({super.key, this.existingCase});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CaseFormBloc>()
            ..add(const LoadCaseFormReferenceDataRequested()),
      child: _CaseFormView(existingCase: existingCase),
    );
  }
}

class _CaseFormView extends StatefulWidget {
  final LegalCase? existingCase;
  const _CaseFormView({this.existingCase});

  @override
  State<_CaseFormView> createState() => _CaseFormViewState();
}

class _CaseFormViewState extends State<_CaseFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _caseNumberController;
  late final TextEditingController _titleController;
  late final TextEditingController _courtCaseNumberController;
  late final TextEditingController _courtCaseYearController;
  late final TextEditingController _agreedFeeController;
  late final TextEditingController _clientNameController;
  late final TextEditingController _clientNationalIdController;
  late final TextEditingController _clientRegistrationController;
  late final TextEditingController _clientPhoneController;
  late final TextEditingController _clientEmailController;
  late final TextEditingController _clientAddressController;
  late final TextEditingController _clientNotesController;
  late final TextEditingController _outcomeSummaryController;
  late CaseStatus _status;
  late CasePriority _priority;
  String? _caseTypeId;
  String _clientType = 'INDIVIDUAL';
  String? _governorateId;
  String? _courtName;
  String? _selectedCourtId;
  String? _circuitId;
  String? _circuitsRequestedForCourtId;
  String? _primaryLawyerId;
  DateTime? _openingDate;
  DateTime? _closingDate;
  bool _showRequiredSelectionErrors = false;
  final List<_OpponentDraft> _opponents = [];
  bool _didLoadInitialCourts = false;
  bool _isLoadingLawyers = false;
  bool _lawyerLoadFailed = false;
  final List<_PrimaryLawyerOption> _lawyers = [];

  bool get _isEditMode => widget.existingCase != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCase;
    _caseNumberController = TextEditingController(text: c?.caseNumber ?? '');
    _titleController = TextEditingController(text: c?.title ?? '');
    _courtCaseNumberController = TextEditingController(
      text: c?.courtCaseNumber ?? '',
    );
    _courtCaseYearController = TextEditingController(
      text: c?.courtCaseYear?.toString() ?? '',
    );
    _agreedFeeController = TextEditingController();
    _clientNameController = TextEditingController();
    _clientNationalIdController = TextEditingController();
    _clientRegistrationController = TextEditingController();
    _clientPhoneController = TextEditingController();
    _clientEmailController = TextEditingController();
    _clientAddressController = TextEditingController();
    _clientNotesController = TextEditingController();
    _outcomeSummaryController = TextEditingController(
      text: c?.description ?? c?.outcomeSummary ?? '',
    );
    _status = c?.status ?? CaseStatus.draft;
    _priority = c?.priority ?? CasePriority.normal;
    _caseTypeId = c?.caseTypeId;
    _governorateId = c?.governorateId;
    _courtName = c?.courtName;
    _circuitId = c?.circuitId;
    _primaryLawyerId = c?.primaryLawyerId;
    _openingDate = c?.openingDate;
    _closingDate = c?.closingDate;
    unawaited(_loadLawyers());
  }

  Future<void> _loadLawyers() async {
    if (!getIt.isRegistered<Dio>()) return;
    setState(() {
      _isLoadingLawyers = true;
      _lawyerLoadFailed = false;
    });
    try {
      final response = await getIt<Dio>().get('/employees');
      final rows = response.data as List<dynamic>;
      final lawyers = rows
          .whereType<Map>()
          .map(
            (row) =>
                _PrimaryLawyerOption.fromJson(Map<String, dynamic>.from(row)),
          )
          .where((lawyer) => lawyer.userId.isNotEmpty)
          .toList();
      if (!mounted) return;
      setState(() {
        _lawyers
          ..clear()
          ..addAll(lawyers);
        _isLoadingLawyers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingLawyers = false;
        _lawyerLoadFailed = true;
      });
    }
  }

  List<_PrimaryLawyerOption> get _matchingLawyers {
    final caseTypeId = _caseTypeId;
    final matches = caseTypeId == null
        ? const <_PrimaryLawyerOption>[]
        : _lawyers
              .where((lawyer) => lawyer.specializations.contains(caseTypeId))
              .toList();
    final selectedId = _primaryLawyerId;
    if (selectedId != null &&
        !matches.any((lawyer) => lawyer.userId == selectedId)) {
      return [
        _PrimaryLawyerOption(
          userId: selectedId,
          name: context.tr('current_primary_lawyer'),
          specializations: const {},
        ),
        ...matches,
      ];
    }
    return matches;
  }

  @override
  void dispose() {
    _caseNumberController.dispose();
    _titleController.dispose();
    _courtCaseNumberController.dispose();
    _courtCaseYearController.dispose();
    _agreedFeeController.dispose();
    _clientNameController.dispose();
    _clientNationalIdController.dispose();
    _clientRegistrationController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _clientAddressController.dispose();
    _clientNotesController.dispose();
    for (final opponent in _opponents) {
      opponent.dispose();
    }
    _outcomeSummaryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context, {
    required bool isOpening,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isOpening ? _openingDate : _closingDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingDate = picked;
        } else {
          _closingDate = picked;
        }
      });
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditMode && _clientNameController.text.trim().isEmpty) {
      setState(() => _showRequiredSelectionErrors = true);
      return;
    }
    final bloc = context.read<CaseFormBloc>();

    if (_isEditMode) {
      final original = widget.existingCase!;
      final request = UpdateCaseRequest(
        title: _changedText(_titleController, original.title),
        courtCaseNumber: _changedText(
          _courtCaseNumberController,
          original.courtCaseNumber,
        ),
        courtCaseYear:
            int.tryParse(_courtCaseYearController.text.trim()) !=
                original.courtCaseYear
            ? int.tryParse(_courtCaseYearController.text.trim())
            : null,
        governorateId: _governorateId != original.governorateId
            ? _governorateId
            : null,
        defaultCourtId: _selectedCourtId,
        circuitId: _circuitId != original.circuitId ? _circuitId : null,
        courtName: _courtName != original.courtName ? _courtName : null,
        openingDate: _openingDate != original.openingDate ? _openingDate : null,
        description:
            _outcomeSummaryController.text.trim() !=
                (original.description ?? original.outcomeSummary ?? '')
            ? (_outcomeSummaryController.text.trim().isEmpty
                  ? null
                  : _outcomeSummaryController.text.trim())
            : null,
        agreedFee: double.tryParse(_agreedFeeController.text.trim()),
        priority: _priority != original.priority ? _priority : null,
        primaryLawyerId: _primaryLawyerId != original.primaryLawyerId
            ? _primaryLawyerId
            : null,
      );
      bloc.add(UpdateCaseSubmitted(original.id, request));
    } else {
      final request = CreateCaseRequest(
        caseNumber: _caseNumberController.text.trim().isEmpty
            ? null
            : _caseNumberController.text.trim(),
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        courtCaseNumber: _optionalText(_courtCaseNumberController),
        courtCaseYear: int.tryParse(_courtCaseYearController.text.trim()),
        caseTypeId: _caseTypeId,
        primaryLawyerId: _primaryLawyerId,
        client: CaseClientInput(
          clientType: _clientType,
          name: _clientNameController.text.trim(),
          nationalId: _optionalText(_clientNationalIdController),
          registrationNo: _optionalText(_clientRegistrationController),
          phone: _optionalText(_clientPhoneController),
          email: _optionalText(_clientEmailController),
          address: _optionalText(_clientAddressController),
          notes: _optionalText(_clientNotesController),
        ),
        opponents: _opponents
            .map(
              (opponent) => CaseOpponentInput(
                opponentType: opponent.type,
                name: opponent.name.text.trim(),
                contact: _optionalText(opponent.contact),
                representative: _optionalText(opponent.representative),
                notes: _optionalText(opponent.notes),
              ),
            )
            .toList(),
        governorateId: _governorateId,
        defaultCourtId: _selectedCourtId,
        circuitId: _circuitId,
        courtName: _courtName,
        status: _status,
        openingDate: _openingDate,
        description: _outcomeSummaryController.text.trim().isEmpty
            ? null
            : _outcomeSummaryController.text.trim(),
        agreedFee: double.tryParse(_agreedFeeController.text.trim()),
        priority: _priority,
      );
      bloc.add(CreateCaseSubmitted(request));
    }
  }

  String? _optionalText(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  String? _changedText(TextEditingController controller, String? original) {
    final value = controller.text.trim();
    return value != (original ?? '') && value.isNotEmpty ? value : null;
  }

  String? _courtCaseYearValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final year = int.tryParse(text);
    if (year == null || year < 1900) {
      return context.tr('invalid_court_case_year');
    }
    return null;
  }

  String? _agreedFeeValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final amount = double.tryParse(text);
    if (amount == null || amount < 0) {
      return context.tr('invalid_amount');
    }
    return null;
  }

  void _addOpponent() {
    setState(() => _opponents.add(_OpponentDraft()));
  }

  void _removeOpponent(int index) {
    final removed = _opponents.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<CaseFormBloc, CaseFormState>(
          listener: _handleFormState,
          child: BlocBuilder<CaseFormBloc, CaseFormState>(
            builder: (context, state) {
              if (state is CaseFormLoading || state is CaseFormInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is! CaseFormReady) return const SizedBox();
              return _buildParityForm(context, state, locale);
            },
          ),
        ),
      ),
    );
  }

  void _handleFormState(BuildContext context, CaseFormState state) {
    if (state is CaseFormSuccess) {
      context.pop(true);
      return;
    }
    if (state is! CaseFormReady) return;
    if (state.submitError != null) {
      final message = state.submitError!.contains(
        'Primary Lawyer specialization does not match',
      )
          ? context.tr('primary_lawyer_ineligible')
          : state.submitError!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    if (!_didLoadInitialCourts && _governorateId != null) {
      _didLoadInitialCourts = true;
      context.read<CaseFormBloc>().add(
        LoadCaseCourtsRequested(_governorateId!),
      );
    }
    if (_selectedCourtId == null &&
        _courtName != null &&
        state.courts.isNotEmpty) {
      for (final court in state.courts) {
        if (court.name == _courtName) {
          setState(() => _selectedCourtId = court.id);
          _circuitsRequestedForCourtId = court.id;
          context.read<CaseFormBloc>().add(
            LoadCaseCircuitsRequested(court.id),
          );
          break;
        }
      }
    }
    if (_selectedCourtId != null &&
        state.courts.any((court) => court.id == _selectedCourtId) &&
        _circuitsRequestedForCourtId != _selectedCourtId) {
      _circuitsRequestedForCourtId = _selectedCourtId;
      context.read<CaseFormBloc>().add(
        LoadCaseCircuitsRequested(_selectedCourtId!),
      );
    }
  }

  Widget _buildParityForm(
    BuildContext context,
    CaseFormReady state,
    Locale locale,
  ) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.s,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CaseFormHeader(isEditMode: _isEditMode),
                const SizedBox(height: AppSpacing.l),
                _FormSection(
                  title: context.tr('case_information'),
                  icon: Icons.description_outlined,
                  child: _ParityFieldGrid(
                    children: [
                      AppTextField(
                        label: _isEditMode
                            ? context.tr('case_number')
                            : context.tr('case_number_optional'),
                        controller: _caseNumberController,
                        readOnly: _isEditMode,
                      ),
                      AppTextField(
                        label: context.tr('case_title'),
                        controller: _titleController,
                      ),
                      if (_isEditMode)
                        _ReadOnlyValueField(
                          label: context.tr('case_type'),
                          value: _resolveCaseTypeLabel(
                            state.caseTypes,
                            widget.existingCase!.caseTypeId,
                            locale,
                            context,
                          ),
                        )
                      else
                        AppDropdownField<String?>(
                          label: context.tr('case_type'),
                          value: _caseTypeId,
                          items: [null, ...state.caseTypes.map((item) => item.id)],
                          labelOf: (id) => id == null
                              ? context.tr('select')
                              : state.caseTypes
                                  .firstWhere((item) => item.id == id)
                                  .labelFor(locale.languageCode),
                          onChanged: (value) => setState(() {
                            _caseTypeId = value;
                            if (!_matchingLawyers.any(
                              (lawyer) => lawyer.userId == _primaryLawyerId,
                            )) {
                              _primaryLawyerId = null;
                            }
                            _showRequiredSelectionErrors = false;
                          }),
                        ),
                      AppDropdownField<CasePriority>(
                        label: context.tr('priority'),
                        value: _priority,
                        items: CasePriority.values.where(
                          (priority) => priority != CasePriority.unknown,
                        ),
                        labelOf: (priority) =>
                            casePriorityLabel(context, priority),
                        onChanged: (value) =>
                            setState(() => _priority = value!),
                      ),
                      AppDateField(
                        label: context.tr('opening_date'),
                        value: _openingDate,
                        dateFormat: DateFormat.yMMMd(locale.languageCode),
                        onTap: () => _pickDate(context, isOpening: true),
                      ),
                      AppTextField(
                        label:
                            '${context.tr('agreed_fee')} (${context.tr('currency_sar').trim()})',
                        controller: _agreedFeeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _agreedFeeValidator,
                      ),
                      AppTextField(
                        label: context.tr('court_case_number'),
                        controller: _courtCaseNumberController,
                      ),
                      AppTextField(
                        label: context.tr('court_case_year'),
                        controller: _courtCaseYearController,
                        keyboardType: TextInputType.number,
                        validator: _courtCaseYearValidator,
                      ),
                      AppTextField(
                        label: context.tr('description_optional'),
                        controller: _outcomeSummaryController,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                _buildCourtSection(context, state, locale),
                const SizedBox(height: AppSpacing.m),
                _buildLawyerSection(context),
                if (!_isEditMode) ...[
                  const SizedBox(height: AppSpacing.m),
                  _buildClientSection(context),
                  const SizedBox(height: AppSpacing.m),
                  _buildOpponentsSection(context),
                ],
                const SizedBox(height: AppSpacing.l),
                _FormActions(
                  isEditMode: _isEditMode,
                  isSubmitting: state.isSubmitting,
                  onCancel: () => context.pop(),
                  onSubmit: () => _submit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourtSection(
    BuildContext context,
    CaseFormReady state,
    Locale locale,
  ) {
    return _FormSection(
      title: context.tr('court_optional'),
      icon: Icons.account_balance_outlined,
      child: Column(
        children: [
          _ParityFieldGrid(
            columns: 3,
            children: [
              AppDropdownField<String?>(
                label: context.tr('governorate'),
                value: _governorateId,
                items: [null, ...state.governorates.map((item) => item.id)],
                labelOf: (id) => id == null
                    ? context.tr('select')
                    : state.governorates
                        .firstWhere((item) => item.id == id)
                        .labelFor(locale.languageCode),
                onChanged: (value) {
                  setState(() {
                    _governorateId = value;
                    _courtName = null;
                    _selectedCourtId = null;
                    _circuitId = null;
                    _circuitsRequestedForCourtId = null;
                  });
                  if (value != null) {
                    context.read<CaseFormBloc>().add(
                      LoadCaseCourtsRequested(value),
                    );
                  }
                },
              ),
              AppDropdownField<String?>(
                label: context.tr('court'),
                value: _selectedCourtId,
                items: [null, ...state.courts.map((item) => item.id)],
                labelOf: (id) => id == null
                    ? context.tr('select')
                    : state.courts.firstWhere((item) => item.id == id).labelFor(locale.languageCode),
                onChanged: _governorateId == null
                    ? (_) {}
                    : (value) {
                        final selected = value == null
                            ? null
                            : state.courts.firstWhere(
                                (item) => item.id == value,
                              );
                        setState(() {
                          _selectedCourtId = value;
                          _courtName = selected?.name;
                          _circuitId = null;
                          _circuitsRequestedForCourtId = value;
                        });
                        if (value != null) {
                          context.read<CaseFormBloc>().add(
                            LoadCaseCircuitsRequested(value),
                          );
                        }
                      },
              ),
              AppDropdownField<String?>(
                label: context.tr('circuit'),
                value: _circuitId,
                items: [null, ...state.circuits.map((item) => item.id)],
                labelOf: (id) => id == null
                    ? context.tr('none')
                    : state.circuits
                        .firstWhere((item) => item.id == id)
                        .labelFor(locale.languageCode),
                onChanged: _selectedCourtId == null
                    ? (_) {}
                    : (value) => setState(() => _circuitId = value),
              ),
            ],
          ),
          if (state.isLoadingCourts) ...[
            const SizedBox(height: AppSpacing.s),
            const LinearProgressIndicator(),
          ] else if (state.courtLoadError != null) ...[
            const SizedBox(height: AppSpacing.s),
            Row(
              children: [
                Expanded(child: Text(context.tr('courts_unavailable'))),
                TextButton(
                  onPressed: _governorateId == null
                      ? null
                      : () => context.read<CaseFormBloc>().add(
                          LoadCaseCourtsRequested(_governorateId!),
                        ),
                  child: Text(context.tr('try_again')),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLawyerSection(BuildContext context) {
    Widget content;
    if (_isLoadingLawyers) {
      content = const LinearProgressIndicator();
    } else if (_lawyerLoadFailed) {
      content = Row(
        children: [
          Expanded(child: Text(context.tr('could_not_load_primary_lawyers'))),
          TextButton(
            onPressed: _loadLawyers,
            child: Text(context.tr('try_again')),
          ),
        ],
      );
    } else if (_caseTypeId == null) {
      content = Text(context.tr('select_case_type_before_lawyer'));
    } else if (_matchingLawyers.isEmpty) {
      content = Text(
        context.tr('no_matching_primary_lawyers'),
        style: AppTypography.bodySmall.copyWith(color: AppColors.brass700),
      );
    } else {
      content = AppDropdownField<String?>(
        label: context.tr('primary_lawyer_optional'),
        value: _primaryLawyerId,
        items: [null, ..._matchingLawyers.map((item) => item.userId)],
        labelOf: (id) => id == null
            ? context.tr('select')
            : _matchingLawyers
                .firstWhere((item) => item.userId == id)
                .name,
        onChanged: (value) => setState(() => _primaryLawyerId = value),
      );
    }
    return _FormSection(
      title: context.tr('responsible_lawyer_optional'),
      icon: Icons.manage_accounts_outlined,
      child: content,
    );
  }

  Widget _buildClientSection(BuildContext context) {
    return _FormSection(
      title: context.tr('client'),
      icon: Icons.person_outline,
      child: _ParityFieldGrid(
        children: [
          AppDropdownField<String>(
            label: context.tr('client_type'),
            value: _clientType,
            items: const ['INDIVIDUAL', 'COMPANY'],
            labelOf: (value) =>
                context.tr(value == 'COMPANY' ? 'company' : 'individual'),
            onChanged: (value) => setState(() => _clientType = value!),
          ),
          AppTextField(
            label: context.tr('client_name'),
            controller: _clientNameController,
            validator: (value) => value == null || value.trim().isEmpty
                ? context.tr('field_required')
                : null,
          ),
          AppTextField(
            label: context.tr('national_id_or_registration'),
            controller: _clientNationalIdController,
          ),
          AppTextField(
            label: context.tr('company_registration_number'),
            controller: _clientRegistrationController,
          ),
          AppTextField(
            label: context.tr('email'),
            controller: _clientEmailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final email = value?.trim() ?? '';
              return email.isNotEmpty && !email.contains('@')
                  ? context.tr('invalid_email')
                  : null;
            },
          ),
          AppTextField(
            label: context.tr('phone'),
            controller: _clientPhoneController,
            keyboardType: TextInputType.phone,
          ),
          AppTextField(
            label: context.tr('address'),
            controller: _clientAddressController,
          ),
          AppTextField(
            label: context.tr('notes'),
            controller: _clientNotesController,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentsSection(BuildContext context) {
    return _FormSection(
      title: context.tr('opponents'),
      icon: Icons.person_off_outlined,
      child: Column(
        children: [
          for (var index = 0; index < _opponents.length; index++) ...[
            _OpponentEditor(
              index: index,
              draft: _opponents[index],
              onTypeChanged: (value) =>
                  setState(() => _opponents[index].type = value),
              onRemove: () => _removeOpponent(index),
            ),
            if (index != _opponents.length - 1)
              const Divider(height: AppSpacing.xl),
          ],
          OutlinedButton.icon(
            onPressed: _addOpponent,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              context.tr(
                _opponents.isEmpty ? 'add_opponent' : 'add_another_opponent',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @Deprecated('Retained temporarily while the parity form is stabilized.')
  Widget buildLegacyForm(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? context.tr('edit_case') : context.tr('new_case'),
        ),
      ),
      body: SafeArea(
        child: BlocListener<CaseFormBloc, CaseFormState>(
          listener: (context, state) {
            if (state is CaseFormSuccess) {
              context.pop(true);
            } else if (state is CaseFormReady && state.submitError != null) {
              final message =
                  state.submitError!.contains(
                    'Primary Lawyer specialization does not match',
                  )
                  ? context.tr('primary_lawyer_ineligible')
                  : state.submitError!;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            }
            if (state is CaseFormReady &&
                !_didLoadInitialCourts &&
                _governorateId != null) {
              _didLoadInitialCourts = true;
              context.read<CaseFormBloc>().add(
                LoadCaseCourtsRequested(_governorateId!),
              );
            }
            if (state is CaseFormReady &&
                _selectedCourtId == null &&
                _courtName != null &&
                state.courts.isNotEmpty) {
              for (final court in state.courts) {
                if (court.name == _courtName) {
                  setState(() => _selectedCourtId = court.id);
                  _circuitsRequestedForCourtId = court.id;
                  context.read<CaseFormBloc>().add(
                    LoadCaseCircuitsRequested(court.id),
                  );
                  break;
                }
              }
            }
            if (state is CaseFormReady &&
                _selectedCourtId != null &&
                state.courts.any((court) => court.id == _selectedCourtId) &&
                _circuitsRequestedForCourtId != _selectedCourtId) {
              _circuitsRequestedForCourtId = _selectedCourtId;
              context.read<CaseFormBloc>().add(
                LoadCaseCircuitsRequested(_selectedCourtId!),
              );
            }
          },
          child: BlocBuilder<CaseFormBloc, CaseFormState>(
            builder: (context, state) {
              if (state is CaseFormLoading || state is CaseFormInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state is! CaseFormReady) return const SizedBox();

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormIntro(isEditMode: _isEditMode),
                      const SizedBox(height: AppSpacing.l),
                      if (_isEditMode) ...[
                        _CaseIdentityCard(
                          caseNumber: widget.existingCase!.caseNumber,
                          caseType: _resolveCaseTypeLabel(
                            state.caseTypes,
                            widget.existingCase!.caseTypeId,
                            locale,
                            context,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        _FormSection(
                          title: context.tr('case_details'),
                          child: Column(
                            children: [
                              AppTextField(
                                label: context.tr('case_title'),
                                controller: _titleController,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('court_case_number'),
                                controller: _courtCaseNumberController,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('court_case_year'),
                                controller: _courtCaseYearController,
                                keyboardType: TextInputType.number,
                                validator: _courtCaseYearValidator,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                      ] else ...[
                        _FormSection(
                          title: context.tr('case_details'),
                          child: Column(
                            children: [
                              AppTextField(
                                label: context.tr('case_number'),
                                controller: _caseNumberController,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('case_title'),
                                controller: _titleController,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('court_case_number'),
                                controller: _courtCaseNumberController,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('court_case_year'),
                                controller: _courtCaseYearController,
                                keyboardType: TextInputType.number,
                                validator: _courtCaseYearValidator,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppDropdownField<String>(
                                label: context.tr('client_type'),
                                value: _clientType,
                                items: const ['INDIVIDUAL', 'COMPANY'],
                                labelOf: (value) => context.tr(
                                  value == 'COMPANY' ? 'company' : 'individual',
                                ),
                                onChanged: (value) =>
                                    setState(() => _clientType = value!),
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('client_name'),
                                controller: _clientNameController,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                    ? context.tr('field_required')
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              if (_clientType == 'INDIVIDUAL')
                                AppTextField(
                                  label: context.tr('national_id'),
                                  controller: _clientNationalIdController,
                                  keyboardType: TextInputType.number,
                                )
                              else
                                AppTextField(
                                  label: context.tr('registration_number'),
                                  controller: _clientRegistrationController,
                                ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('phone'),
                                controller: _clientPhoneController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('email'),
                                controller: _clientEmailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isNotEmpty &&
                                      !email.contains('@')) {
                                    return context.tr('invalid_email');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('address'),
                                controller: _clientAddressController,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppTextField(
                                label: context.tr('notes'),
                                controller: _clientNotesController,
                              ),
                              const SizedBox(height: AppSpacing.m),
                              AppDropdownField<String?>(
                                label: context.tr('case_type'),
                                value: _caseTypeId,
                                items: state.caseTypes.map((l) => l.id),
                                labelOf: (id) => id == null
                                    ? context.tr('none')
                                    : state.caseTypes
                                          .firstWhere((l) => l.id == id)
                                          .labelFor(locale.languageCode),
                                onChanged: (v) => setState(() {
                                  _caseTypeId = v;
                                  if (!_matchingLawyers.any(
                                    (lawyer) =>
                                        lawyer.userId == _primaryLawyerId,
                                  )) {
                                    _primaryLawyerId = null;
                                  }
                                  _showRequiredSelectionErrors = false;
                                }),
                              ),
                              if (_showRequiredSelectionErrors &&
                                  _caseTypeId == null)
                                _RequiredSelectionError(
                                  message: context.tr('field_required'),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        _FormSection(
                          title: context.tr('opponents'),
                          child: Column(
                            children: [
                              if (_opponents.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.s,
                                  ),
                                  child: Text(
                                    context.tr('no_opponents_added'),
                                    style: AppTypography.bodySmall,
                                  ),
                                ),
                              for (
                                var index = 0;
                                index < _opponents.length;
                                index++
                              ) ...[
                                _OpponentEditor(
                                  index: index,
                                  draft: _opponents[index],
                                  onTypeChanged: (value) => setState(
                                    () => _opponents[index].type = value,
                                  ),
                                  onRemove: () => _removeOpponent(index),
                                ),
                                if (index != _opponents.length - 1)
                                  const Divider(height: AppSpacing.xl),
                              ],
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: TextButton.icon(
                                  onPressed: _addOpponent,
                                  icon: const Icon(Icons.person_add_outlined),
                                  label: Text(context.tr('add_opponent')),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                      ],
                      _FormSection(
                        title: context.tr('case_details'),
                        child: Column(
                          children: [
                            if (!_isEditMode)
                              AppDropdownField<CaseStatus>(
                                label: context.tr('status'),
                                value: _status,
                                items: const [CaseStatus.draft],
                                labelOf: (s) => caseStatusLabel(context, s),
                                onChanged: (v) => setState(() => _status = v!),
                              ),
                            const SizedBox(height: AppSpacing.m),
                            AppDropdownField<CasePriority>(
                              label: context.tr('priority'),
                              value: _priority,
                              items: CasePriority.values.where(
                                (p) => p != CasePriority.unknown,
                              ),
                              labelOf: (p) => casePriorityLabel(context, p),
                              onChanged: (v) => setState(() => _priority = v!),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            if (_isLoadingLawyers)
                              const LinearProgressIndicator()
                            else if (_lawyerLoadFailed)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.m),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        context.tr(
                                          'could_not_load_primary_lawyers',
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.s),
                                      TextButton(
                                        onPressed: _loadLawyers,
                                        child: Text(context.tr('try_again')),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (_caseTypeId == null)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.m),
                                  child: Text(
                                    context.tr(
                                      'select_case_type_before_lawyer',
                                    ),
                                  ),
                                ),
                              )
                            else if (_matchingLawyers.isEmpty)
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.m),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        context.tr(
                                          'no_matching_primary_lawyers',
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.s),
                                      TextButton.icon(
                                        onPressed: _loadLawyers,
                                        icon: const Icon(Icons.refresh),
                                        label: Text(context.tr('try_again')),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              AppDropdownField<String?>(
                                label: context.tr('primary_lawyer_optional'),
                                value: _primaryLawyerId,
                                items: [
                                  null,
                                  ..._matchingLawyers.map(
                                    (lawyer) => lawyer.userId,
                                  ),
                                ],
                                labelOf: (id) => id == null
                                    ? context.tr('none')
                                    : _matchingLawyers
                                          .firstWhere(
                                            (lawyer) => lawyer.userId == id,
                                          )
                                          .name,
                                onChanged: (value) =>
                                    setState(() => _primaryLawyerId = value),
                              ),
                            const SizedBox(height: AppSpacing.m),
                            AppDropdownField<String?>(
                              label: context.tr('governorate'),
                              value: _governorateId,
                              items: [
                                null,
                                ...state.governorates.map((g) => g.id),
                              ],
                              labelOf: (id) => id == null
                                  ? context.tr('none')
                                  : state.governorates
                                        .firstWhere((g) => g.id == id)
                                        .labelFor(locale.languageCode),
                              onChanged: (v) {
                                setState(() {
                                  _governorateId = v;
                                  _courtName = null;
                                  _selectedCourtId = null;
                                  _circuitId = null;
                                  _circuitsRequestedForCourtId = null;
                                });
                                if (v != null) {
                                  context.read<CaseFormBloc>().add(
                                    LoadCaseCourtsRequested(v),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.m),
                            AppDropdownField<String?>(
                              label: context.tr('court'),
                              value:
                                  _selectedCourtId ??
                                  (_courtName == null
                                      ? null
                                      : 'stored:${_courtName!}'),
                              items: [
                                null,
                                if (_courtName != null &&
                                    _selectedCourtId == null)
                                  'stored:${_courtName!}',
                                ...state.courts.map((court) => court.id),
                              ],
                              labelOf: (id) {
                                if (id == null) return context.tr('none');
                                if (id.startsWith('stored:')) {
                                  return id.substring('stored:'.length);
                                }
                                return state.courts
                                    .firstWhere((court) => court.id == id)
                                    .labelFor(locale.languageCode);
                              },
                              onChanged: (v) {
                                if (v?.startsWith('stored:') ?? false) return;
                                final selected = v == null
                                    ? null
                                    : state.courts.firstWhere(
                                        (court) => court.id == v,
                                      );
                                setState(() {
                                  _selectedCourtId = v;
                                  _courtName = selected?.name;
                                  _circuitId = null;
                                  _circuitsRequestedForCourtId = v;
                                });
                                if (v != null) {
                                  context.read<CaseFormBloc>().add(
                                    LoadCaseCircuitsRequested(v),
                                  );
                                }
                              },
                            ),
                            if (_selectedCourtId != null) ...[
                              const SizedBox(height: AppSpacing.m),
                              if (state.circuits.isEmpty)
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Text(
                                    context.tr('no_circuits_optional'),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              else
                                AppDropdownField<String?>(
                                  label: context.tr('circuit'),
                                  value: _circuitId,
                                  items: [
                                    null,
                                    ...state.circuits.map(
                                      (circuit) => circuit.id,
                                    ),
                                  ],
                                  labelOf: (id) => id == null
                                      ? context.tr('none')
                                      : state.circuits
                                            .firstWhere(
                                              (circuit) => circuit.id == id,
                                            )
                                            .labelFor(locale.languageCode),
                                  onChanged: (value) =>
                                      setState(() => _circuitId = value),
                                ),
                            ],
                            if (state.isLoadingCourts) ...[
                              const SizedBox(height: AppSpacing.s),
                              const LinearProgressIndicator(),
                            ] else if (state.courtLoadError != null) ...[
                              const SizedBox(height: AppSpacing.s),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      context.tr('courts_unavailable'),
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _governorateId == null
                                        ? null
                                        : () =>
                                              context.read<CaseFormBloc>().add(
                                                LoadCaseCourtsRequested(
                                                  _governorateId!,
                                                ),
                                              ),
                                    child: Text(context.tr('try_again')),
                                  ),
                                ],
                              ),
                            ] else if (_governorateId != null &&
                                state.courts.isEmpty) ...[
                              const SizedBox(height: AppSpacing.s),
                              Text(
                                context.tr('courts_unavailable'),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      _FormSection(
                        title: context.tr('case_details'),
                        child: Column(
                          children: [
                            AppDateField(
                              label: context.tr('opening_date'),
                              value: _openingDate,
                              dateFormat: DateFormat.yMMMd(),
                              onTap: () => _pickDate(context, isOpening: true),
                            ),
                            const SizedBox(height: AppSpacing.m),
                            AppTextField(
                              label: context.tr('description'),
                              controller: _outcomeSummaryController,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: _isEditMode
                            ? context.tr('save_changes')
                            : context.tr('create_case'),
                        isLoading: state.isSubmitting,
                        onPressed: () => _submit(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _resolveCaseTypeLabel(
    List<CaseTypeReference> caseTypes,
    String? caseTypeId,
    Locale locale,
    BuildContext context,
  ) {
    for (final lookup in caseTypes) {
      if (lookup.id == caseTypeId) {
        return lookup.labelFor(locale.languageCode);
      }
    }
    return context.tr('unknown');
  }
}

class _PrimaryLawyerOption {
  const _PrimaryLawyerOption({
    required this.userId,
    required this.name,
    required this.specializations,
  });

  final String userId;
  final String name;
  final Set<String> specializations;

  factory _PrimaryLawyerOption.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    return _PrimaryLawyerOption(
      userId: json['userId']?.toString() ?? user['id']?.toString() ?? '',
      name: user['fullName']?.toString() ?? '',
      specializations: Set<String>.from(
        json['specializations'] as List? ?? const [],
      ),
    );
  }
}

class _FormIntro extends StatelessWidget {
  const _FormIntro({required this.isEditMode});

  final bool isEditMode;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.m),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: AppRadius.large,
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.gavel_outlined, color: Colors.white),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Text(
            isEditMode
                ? context.tr('update_case_details')
                : context.tr('start_new_case'),
            style: AppTypography.h3,
          ),
        ),
      ],
    ),
  );
}

class _CaseFormHeader extends StatelessWidget {
  const _CaseFormHeader({required this.isEditMode});

  final bool isEditMode;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: context.tr('back'),
        onPressed: () => context.pop(),
        icon: Directionality.of(context) == ui.TextDirection.rtl
            ? const Icon(Icons.arrow_forward)
            : const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: AppSpacing.s),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditMode ? context.tr('edit_case') : context.tr('new_case'),
              style: AppTypography.h1,
            ),
            const SizedBox(height: 3),
            Text(
              isEditMode
                  ? context.tr('update_case_details')
                  : context.tr('start_new_case'),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ParityFieldGrid extends StatelessWidget {
  const _ParityFieldGrid({required this.children, this.columns = 2});

  final List<Widget> children;
  final int columns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final effectiveColumns = constraints.maxWidth < 640 ? 1 : columns;
      const gap = AppSpacing.m;
      final width =
          (constraints.maxWidth - gap * (effectiveColumns - 1)) /
          effectiveColumns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _ReadOnlyValueField extends StatelessWidget {
  const _ReadOnlyValueField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label.toUpperCase(),
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.1,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.paperSoft,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.paperLine),
        ),
        child: Text(value, style: AppTypography.bodyMedium),
      ),
    ],
  );
}

class _FormActions extends StatelessWidget {
  const _FormActions({
    required this.isEditMode,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isEditMode;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 480;
      final buttons = [
        SizedBox(
          width: compact ? double.infinity : 150,
          child: AppButton(
            text: context.tr('cancel'),
            style: AppButtonStyle.secondary,
            onPressed: isSubmitting ? null : onCancel,
          ),
        ),
        SizedBox(
          width: compact ? double.infinity : 190,
          child: AppButton(
            text: isEditMode
                ? context.tr('save_changes')
                : context.tr('create_case'),
            isLoading: isSubmitting,
            onPressed: onSubmit,
          ),
        ),
      ];
      return compact
          ? Column(
              children: [
                buttons[1],
                const SizedBox(height: AppSpacing.s),
                buttons[0],
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [buttons[0], const SizedBox(width: 12), buttons[1]],
            );
    },
  );
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child, this.icon});

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.m),
    decoration: BoxDecoration(
      color: AppColors.paperSoft.withValues(alpha: 0.62),
      borderRadius: AppRadius.large,
      border: Border.all(color: AppColors.paperLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19, color: AppColors.brass700),
              const SizedBox(width: AppSpacing.s),
            ],
            Expanded(child: Text(title, style: AppTypography.h3)),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        child,
      ],
    ),
  );
}

class _RequiredSelectionError extends StatelessWidget {
  const _RequiredSelectionError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6, left: 12),
    child: Text(
      message,
      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
    ),
  );
}

class _OpponentDraft {
  String type = 'INDIVIDUAL';
  final name = TextEditingController();
  final contact = TextEditingController();
  final representative = TextEditingController();
  final notes = TextEditingController();

  void dispose() {
    name.dispose();
    contact.dispose();
    representative.dispose();
    notes.dispose();
  }
}

class _OpponentEditor extends StatelessWidget {
  const _OpponentEditor({
    required this.index,
    required this.draft,
    required this.onTypeChanged,
    required this.onRemove,
  });

  final int index;
  final _OpponentDraft draft;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              '${context.tr('opponent')} ${index + 1}',
              style: AppTypography.labelLarge,
            ),
          ),
          IconButton(
            tooltip: context.tr('remove_opponent'),
            onPressed: onRemove,
            icon: const Icon(Icons.close, color: AppColors.error),
          ),
        ],
      ),
      AppDropdownField<String>(
        label: context.tr('opponent_type'),
        value: draft.type,
        items: const ['INDIVIDUAL', 'COMPANY'],
        labelOf: (value) =>
            context.tr(value == 'COMPANY' ? 'company' : 'individual'),
        onChanged: (value) => onTypeChanged(value!),
      ),
      const SizedBox(height: AppSpacing.m),
      AppTextField(
        label: context.tr('opponent_name'),
        controller: draft.name,
        validator: (value) => value == null || value.trim().isEmpty
            ? context.tr('field_required')
            : null,
      ),
      const SizedBox(height: AppSpacing.m),
      AppTextField(
        label: context.tr('contact_details'),
        controller: draft.contact,
      ),
      const SizedBox(height: AppSpacing.m),
      AppTextField(
        label: context.tr('representative'),
        controller: draft.representative,
      ),
      const SizedBox(height: AppSpacing.m),
      AppTextField(label: context.tr('notes'), controller: draft.notes),
    ],
  );
}

class _CaseIdentityCard extends StatelessWidget {
  const _CaseIdentityCard({required this.caseNumber, required this.caseType});

  final String caseNumber;
  final String caseType;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.m),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: AppRadius.large,
      border: Border.all(color: AppColors.surfaceLight),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caseNumber, style: AppTypography.labelLarge),
        const SizedBox(height: 4),
        Text(caseType, style: AppTypography.bodySmall),
      ],
    ),
  );
}
