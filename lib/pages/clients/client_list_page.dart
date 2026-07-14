import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../widgets/clients/client_form_dialog.dart';
import '../../widgets/clients/client_table.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.clientAddedMessage), backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _openEditDialog(Client client) async {
    final bool? result = await ClientFormDialog.show(context, client: client);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.clientUpdatedMessage), backgroundColor: AppColors.success),
      );
    }
  }

  void _viewClient(Client client) {
    Navigator.of(context).pushNamed(AppRoutes.clientDetails, arguments: client.id);
  }

  Future<void> _deactivateClient(Client client) async {
    final bool confirmed = await ConfirmationDialog.show(
      context,
      title: AppStrings.deactivateClientTitle,
      message: 'Are you sure you want to deactivate "${client.companyName}"?',
      confirmLabel: 'Deactivate',
      isDanger: true,
    );
    if (!confirmed || !mounted) return;

    final ClientProvider provider = context.read<ClientProvider>();
    final bool success = await provider.deactivateClient(client.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? AppStrings.clientDeactivatedMessage : (provider.errorMessage ?? 'Failed to deactivate client.'),
        ),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
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
                const SizedBox(height: AppSpacing.lg),
                Expanded(child: _buildContent(provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ClientProvider provider) {
    if (provider.isLoading && provider.clients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.clients.isEmpty) {
      return AppErrorState(message: provider.errorMessage!, onRetry: provider.loadClients);
    }

    if (provider.clients.isEmpty) {
      return const PlaceholderPageContent(
        icon: Icons.business_outlined,
        title: AppStrings.clientsEmptyMessage,
        message: 'Try adjusting your search or filters, or add a new client.',
      );
    }

    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: ClientTable(
            clients: provider.clients,
            onView: _viewClient,
            onEdit: _openEditDialog,
            onDeactivate: _deactivateClient,
          ),
        ),
      ),
    );
  }
}
