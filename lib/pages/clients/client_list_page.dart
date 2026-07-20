import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../models/client.dart';
import '../../models/status.dart';
import '../../providers/client_provider.dart';
import '../../widgets/clients/client_form_dialog.dart';
import '../../widgets/clients/client_table.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/list_page_toolbar.dart';
import '../../widgets/common/placeholder_page_content.dart';
import '../../widgets/layout/app_shell.dart';

/// Client management page (UI/UX spec Section 11): search, status
/// filter, Add/Edit/Deactivate actions, and the client table. Mirrors
/// [EmployeeListPage]'s structure, reusing the same shared toolbar,
/// error state, and empty-state widgets.
class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ClientProvider>().loadClients();
    });
  }

  Future<void> _openAddDialog() async {
    final bool? result = await ClientFormDialog.show(context);
    if (result == true && mounted) {
      AppSnackBar.showSuccess(context, AppStrings.clientAddedMessage);
    }
  }

  Future<void> _openEditDialog(Client client) async {
    final bool? result = await ClientFormDialog.show(context, client: client);
    if (result == true && mounted) {
      AppSnackBar.showSuccess(context, AppStrings.clientUpdatedMessage);
    }
  }

  void _viewClient(Client client) {
    Navigator.of(context).pushNamed(AppRoutes.clientDetails, arguments: client.id);
  }

  Future<void> _toggleClientStatus(Client client) async {
    final bool isActivating = client.status == Status.inactive;

    final bool confirmed = await ConfirmationDialog.show(
      context,
      title: isActivating ? AppStrings.activateClientTitle : AppStrings.deactivateClientTitle,
      message: isActivating
          ? 'Activate this client?'
          : 'Are you sure you want to deactivate "${client.companyName}"?',
      confirmLabel: isActivating ? 'Activate' : 'Deactivate',
      isDanger: !isActivating,
    );
    if (!confirmed || !mounted) return;

    final ClientProvider provider = context.read<ClientProvider>();
    final bool success = isActivating
        ? await provider.activateClient(client.id)
        : await provider.deactivateClient(client.id);
    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(
        context,
        isActivating ? AppStrings.clientActivatedMessage : AppStrings.clientDeactivatedMessage,
      );
    } else {
      AppSnackBar.showError(context, provider.errorMessage ?? 'Failed to update client status.');
    }
  }

  Future<void> _deleteClient(Client client) async {
    final bool confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Client',
      message: 'Permanently delete "${client.companyName}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (!confirmed || !mounted) return;

    final ClientProvider provider = context.read<ClientProvider>();
    final bool success = await provider.deleteClient(client.id);
    if (!mounted) return;

    if (success) {
      AppSnackBar.showSuccess(context, 'Client deleted successfully.');
    } else {
      AppSnackBar.showError(context, provider.errorMessage ?? 'Failed to delete client.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.clients,
      body: Consumer<ClientProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListPageToolbar(
                  searchHint: AppStrings.searchClientsHint,
                  initialSearchValue: provider.searchQuery,
                  onSearch: provider.search,
                  statusFilter: provider.statusFilter,
                  onFilterChanged: provider.filterByStatus,
                  addButtonLabel: AppStrings.addClientTitle,
                  onAddPressed: _openAddDialog,
                ),
                const SizedBox(height: AppSpacing.md),
                // Thin progress indicator during search/filter refetch,
                // separate from the full-page spinner shown only on the
                // very first load — keeps the existing table visible
                // while new results come in.
                SizedBox(
                  height: 2,
                  child: provider.isLoading && provider.clients.isNotEmpty
                      ? const LinearProgressIndicator(minHeight: 2)
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildContent(provider),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ClientProvider provider) {
    if (provider.isLoading && provider.clients.isEmpty) {
      return const Center(key: ValueKey('loading'), child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.clients.isEmpty) {
      return AppErrorState(
        key: const ValueKey('error'),
        message: provider.errorMessage!,
        onRetry: provider.loadClients,
      );
    }

    if (provider.clients.isEmpty) {
      return const PlaceholderPageContent(
        key: ValueKey('empty'),
        icon: Icons.business_outlined,
        title: AppStrings.clientsEmptyMessage,
        message: 'Try adjusting your search or filters, or add a new client.',
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('content'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: ClientTable(
            clients: provider.clients,
            onView: _viewClient,
            onEdit: _openEditDialog,
            onToggleStatus: _toggleClientStatus,
            onDelete: _deleteClient,
          ),
        ),
      ),
    );
  }
}
