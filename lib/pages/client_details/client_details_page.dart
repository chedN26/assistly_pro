import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../widgets/clients/add_payment_dialog.dart';
import '../../widgets/clients/client_info_card.dart';
import '../../widgets/clients/client_revenue_chart.dart';
import '../../widgets/clients/payment_history_table.dart';
import '../../widgets/common/chart_card.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/placeholder_page_content.dart';
import '../../widgets/layout/app_shell.dart';

/// Client details page (UI/UX spec Section 12): company information
/// card, payment history table, Add Payment action, and monthly
/// revenue chart. [clientId] arrives via `Navigator` route arguments
/// from the client table's "View" action. Mirrors
/// [EmployeeDetailsPage]'s structure.
class ClientDetailsPage extends StatefulWidget {
  const ClientDetailsPage({super.key, this.clientId});

  final String? clientId;

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  Client? _client;
  bool _isLoadingClient = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final String? id = widget.clientId;
    if (id == null) {
      if (!mounted) return;
      setState(() {
        _isLoadingClient = false;
        _loadError = 'No client specified.';
      });
      return;
    }

    final ClientProvider provider = context.read<ClientProvider>();
    // Fast path: check the already-loaded list first. Falls back to a
    // direct repository fetch for cases where the list hasn't been
    // loaded yet (e.g. a fresh page load via direct navigation).
    Client? client = provider.getById(id);
    client ??= await provider.fetchById(id);

    if (!mounted) return;

    if (client == null) {
      setState(() {
        _isLoadingClient = false;
        _loadError = 'Client not found.';
      });
      return;
    }

    setState(() {
      _client = client;
      _isLoadingClient = false;
    });

    await provider.loadPayments(id);
  }

  Future<void> _openAddPaymentDialog() async {
    final Client? client = _client;
    if (client == null) return;

    final bool? result = await AddPaymentDialog.show(context, clientId: client.id);
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.paymentAddedMessage), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.clientDetails,
      pageTitle: _client?.companyName ?? AppStrings.pageTitleClientDetails,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoadingClient) {
      return const Center(child: CircularProgressIndicator());
    }

    final Client? client = _client;
    if (_loadError != null || client == null) {
      return AppErrorState(
        message: _loadError ?? 'Client not found.',
        onRetry: () {
          setState(() => _isLoadingClient = true);
          _load();
        },
      );
    }

    return Consumer<ClientProvider>(
      builder: (context, provider, _) {
        final payments = provider.paymentsFor(client.id);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _ClientBackButton(),
              const SizedBox(height: AppSpacing.md),
              ClientInfoCard(client: client),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment History', style: Theme.of(context).textTheme.titleMedium),
                  ElevatedButton.icon(
                    onPressed: _openAddPaymentDialog,
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addPaymentTitle),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (provider.isLoadingPayments && payments.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (payments.isEmpty)
                const PlaceholderPageContent(
                  icon: Icons.receipt_long_outlined,
                  title: AppStrings.clientPaymentsEmptyMessage,
                  message: 'Add the first payment using the button above.',
                )
              else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: PaymentHistoryTable(payments: payments),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ChartCard(
                  title: 'Monthly Revenue',
                  child: ClientRevenueChart(payments: payments),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ClientBackButton extends StatelessWidget {
  const _ClientBackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.clients);
          }
        },
        icon: const Icon(Icons.arrow_back),
        label: const Text('Back'),
      ),
    );
  }
}
