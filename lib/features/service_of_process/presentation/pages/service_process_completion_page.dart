import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../di/injection.dart';
import '../../../documents/domain/upload_file_validation.dart';
import '../../domain/entities/service_process.dart';
import '../../domain/entities/service_status.dart';
import '../bloc/service_process_completion_bloc.dart';
import '../service_process_display_helpers.dart';

class ServiceProcessCompletionPage extends StatelessWidget {
  const ServiceProcessCompletionPage({super.key, required this.process});
  final ServiceProcess process;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<ServiceProcessCompletionBloc>()
          ..add(LoadServiceCompletionRequested()),
    child: _CompletionView(process: process),
  );
}

class _CompletionView extends StatefulWidget {
  const _CompletionView({required this.process});
  final ServiceProcess process;

  @override
  State<_CompletionView> createState() => _CompletionViewState();
}

class _CompletionViewState extends State<_CompletionView> {
  final _notes = TextEditingController();
  ServiceStatus _status = ServiceStatus.completed;
  String? _categoryId;
  String? _filePath;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickEvidence() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: kAllowedUploadExtensions,
    );
    final path = result?.files.single.path;
    if (path == null) return;
    final error = validateUploadFile(path, await File(path).length());
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              error == UploadValidationError.tooLarge
                  ? 'upload_file_too_large'
                  : 'upload_file_type_unsupported',
            ),
          ),
        ),
      );
      return;
    }
    setState(() => _filePath = path);
  }

  void _submit() {
    final notes = _notes.text.trim();
    if (notes.isEmpty || _categoryId == null || _filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('complete_service_evidence_fields'))),
      );
      return;
    }
    context.read<ServiceProcessCompletionBloc>().add(
      SubmitServiceCompletionRequested(
        process: widget.process,
        status: _status,
        resultNotes: notes,
        filePath: _filePath!,
        categoryId: _categoryId!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(context.tr('complete_service_process'))),
      body:
          BlocConsumer<
            ServiceProcessCompletionBloc,
            ServiceProcessCompletionState
          >(
            listener: (context, state) {
              if (state is ServiceProcessCompletionSuccess) {
                context.pop(true);
              } else if (state is ServiceProcessCompletionReady &&
                  state.submitError != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.submitError!)));
              }
            },
            builder: (context, state) {
              if (state is ServiceProcessCompletionInitial ||
                  state is ServiceProcessCompletionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ServiceProcessCompletionFailure) {
                return Center(child: Text(state.message));
              }
              if (state is! ServiceProcessCompletionReady) {
                return const SizedBox();
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Column(
                  children: [
                    AppDropdownField<ServiceStatus>(
                      label: context.tr('completion_result'),
                      value: _status,
                      items: const [
                        ServiceStatus.completed,
                        ServiceStatus.failed,
                      ],
                      labelOf: (value) => serviceStatusLabel(context, value),
                      onChanged: (value) => setState(() => _status = value!),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    AppTextField(
                      label: context.tr('result_notes'),
                      controller: _notes,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    AppDropdownField<String?>(
                      label: context.tr('document_category'),
                      value: _categoryId,
                      items: state.categories.map((item) => item.id),
                      labelOf: (id) => state.categories
                          .firstWhere((item) => item.id == id)
                          .labelFor(locale),
                      onChanged: (value) => setState(() => _categoryId = value),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    ListTile(
                      tileColor: AppColors.surface,
                      leading: const Icon(Icons.attach_file),
                      title: Text(
                        _filePath == null
                            ? context.tr('choose_evidence_file')
                            : _filePath!.split(RegExp(r'[/\\]')).last,
                      ),
                      onTap: state.isSubmitting ? null : _pickEvidence,
                    ),
                    if (state.isSubmitting) ...[
                      const SizedBox(height: AppSpacing.m),
                      LinearProgressIndicator(value: state.progress),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      text: context.tr('submit_completion'),
                      isLoading: state.isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
