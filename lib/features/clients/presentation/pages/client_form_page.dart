import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../data/models/create_client_request.dart';
import '../../data/models/update_client_request.dart';
import '../../domain/entities/client.dart';
import '../../domain/entities/client_type.dart';
import '../bloc/client_form_bloc.dart';
import '../client_display_helpers.dart';

/// Shared Create/Edit screen — `existingClient == null` means create mode.
/// On success, pops with `true` so the caller (`ClientsPage`/
/// `ClientProfilePage`) knows to refetch — this bloc never refetches
/// anything itself, per the project's explicit-refetch convention.
class ClientFormPage extends StatelessWidget {
  final Client? existingClient;

  const ClientFormPage({super.key, this.existingClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClientFormBloc>(),
      child: _ClientFormView(existingClient: existingClient),
    );
  }
}

class _ClientFormView extends StatefulWidget {
  final Client? existingClient;
  const _ClientFormView({this.existingClient});

  @override
  State<_ClientFormView> createState() => _ClientFormViewState();
}

class _ClientFormViewState extends State<_ClientFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientCodeController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _commercialRegController;
  late final TextEditingController _emailsController;
  late final TextEditingController _phonesController;
  late final TextEditingController _addressesController;
  late ClientType _type;

  bool get _isEditMode => widget.existingClient != null;

  @override
  void initState() {
    super.initState();
    final client = widget.existingClient;
    _clientCodeController = TextEditingController(
      text: client?.clientCode ?? '',
    );
    _fullNameController = TextEditingController(text: client?.fullName ?? '');
    _nationalIdController = TextEditingController(
      text: client?.nationalId ?? '',
    );
    _commercialRegController = TextEditingController(
      text: client?.commercialReg ?? '',
    );
    _emailsController = TextEditingController(
      text: (client?.emails ?? const []).join(', '),
    );
    _phonesController = TextEditingController(
      text: (client?.phones ?? const []).join(', '),
    );
    _addressesController = TextEditingController(
      text: (client?.addresses ?? const []).join(', '),
    );
    _type = client?.type ?? ClientType.individual;
  }

  @override
  void dispose() {
    _clientCodeController.dispose();
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _commercialRegController.dispose();
    _emailsController.dispose();
    _phonesController.dispose();
    _addressesController.dispose();
    super.dispose();
  }

  List<String>? _parseList(String text) {
    final items = text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return items.isEmpty ? null : items;
  }

  String? _blankToNull(String text) => text.trim().isEmpty ? null : text.trim();

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<ClientFormBloc>();
    if (_isEditMode) {
      final original = widget.existingClient!;
      final request = UpdateClientRequest(
        clientCode: _clientCodeController.text.trim() != original.clientCode
            ? _clientCodeController.text.trim()
            : null,
        type: _type != original.type ? _type : null,
        fullName: _fullNameController.text.trim() != original.fullName
            ? _fullNameController.text.trim()
            : null,
        nationalId:
            _blankToNull(_nationalIdController.text) != original.nationalId
            ? _blankToNull(_nationalIdController.text)
            : null,
        commercialReg:
            _blankToNull(_commercialRegController.text) !=
                original.commercialReg
            ? _blankToNull(_commercialRegController.text)
            : null,
        emails: _parseList(_emailsController.text) != original.emails
            ? _parseList(_emailsController.text)
            : null,
        phones: _parseList(_phonesController.text) != original.phones
            ? _parseList(_phonesController.text)
            : null,
        addresses: _parseList(_addressesController.text) != original.addresses
            ? _parseList(_addressesController.text)
            : null,
      );
      bloc.add(UpdateClientSubmitted(original.id, request));
    } else {
      final request = CreateClientRequest(
        clientCode: _clientCodeController.text.trim(),
        type: _type,
        fullName: _fullNameController.text.trim(),
        nationalId: _blankToNull(_nationalIdController.text),
        commercialReg: _blankToNull(_commercialRegController.text),
        emails: _parseList(_emailsController.text),
        phones: _parseList(_phonesController.text),
        addresses: _parseList(_addressesController.text),
      );
      bloc.add(CreateClientSubmitted(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? context.tr('edit_client') : context.tr('new_client'),
        ),
      ),
      body: SafeArea(
        child: BlocListener<ClientFormBloc, ClientFormState>(
          listener: (context, state) {
            if (state is ClientFormSuccess) {
              context.pop(true);
            } else if (state is ClientFormFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<ClientFormBloc, ClientFormState>(
            builder: (context, state) {
              final isSubmitting = state is ClientFormSubmitting;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: context.tr('client_code'),
                        controller: _clientCodeController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? context.tr('field_required')
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        context.tr('client_type').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ClientType>(
                            value: _type,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            items: [ClientType.individual, ClientType.company]
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(clientTypeLabel(context, t)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => _type = value);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('full_name'),
                        controller: _fullNameController,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? context.tr('field_required')
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('national_id'),
                        controller: _nationalIdController,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('commercial_reg'),
                        controller: _commercialRegController,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('emails'),
                        hint: 'a@example.com, b@example.com',
                        controller: _emailsController,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('phones'),
                        hint: '+1 555-0100, +1 555-0200',
                        controller: _phonesController,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      AppTextField(
                        label: context.tr('addresses'),
                        controller: _addressesController,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        text: _isEditMode
                            ? context.tr('save_changes')
                            : context.tr('create_client'),
                        isLoading: isSubmitting,
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
}
