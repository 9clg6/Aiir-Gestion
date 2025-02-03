import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:init/foundation/enums/headers.enum.dart';
import 'package:init/foundation/extensions/date_time.extension.dart';
import 'package:init/ui/screen/main/index.view_model.dart';
import 'package:init/ui/screen/main/index.view_state.dart';
import 'package:init/ui/widgets/status_card.dart';

/// Main screen
class MainScreen extends ConsumerStatefulWidget {
  /// Constructor
  const MainScreen({super.key});

  /// Creates the state of the main screen
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainScreenState();
}

/// State of the main screen
class _MainScreenState extends ConsumerState<MainScreen> {
  /// Builds the main screen
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          _ResumeHeader(),
          _ManagementBar(),
          _Body(),
        ],
      ),
    );
  }
}

class _PinnedOrders extends ConsumerWidget {
  const _PinnedOrders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IndexScreenState state = ref.watch(indexProvider);
    if (state.pinnedOrders.isEmpty) return const SizedBox();

    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = ref.read(indexProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 22,
              top: 22,
              bottom: 10,
            ),
            child: Text(
              "Commandes épinglées",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 46,
              border: TableBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    overflow: TextOverflow.ellipsis,
                  ),
              headingTextStyle:
                  Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
              showCheckboxColumn: false,
              horizontalMargin: 12,
              dividerThickness: .5,
              columns: Headers.values
                  .map((e) => DataColumn(
                        label: Text(e.label),
                        numeric: e.isNumeric,
                        headingRowAlignment: MainAxisAlignment.center,
                      ))
                  .toList(),
              rows: state.pinnedOrders.map((order) {
                return DataRow(
                  onSelectChanged: (_) {
                    if (context.mounted) {
                      context.pushNamed(
                        'order-details',
                        pathParameters: {'orderId': order.id},
                        extra: order,
                      );
                    }
                  },
                  cells: [
                    DataCell(
                      Center(
                        child: Hero(
                          tag: 'order-${order.id}',
                          child: Text(order.clientContact),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: StatusCard(status: order.status),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(order.shopName),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(order.startDate.toDDMMYYYY()),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(order.endDate?.toDDMMYYYY() ?? ""),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text("${order.price}€"),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text("${order.commission}€"),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          onPressed: () {
                            if (context.mounted) {
                              context.pushNamed(
                                'order-details',
                                pathParameters: {'orderId': order.id},
                                extra: order,
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_new),
                          tooltip: "Ouvrir",
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          onPressed: () => viewModel.pinOrder(order),
                          icon: Icon(state.pinnedOrders.contains(order)
                              ? Icons.push_pin
                              : Icons.push_pin_outlined),
                          tooltip: "Épingler",
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IndexScreenState state = ref.watch(indexProvider);

    if (state.loading) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SliverPadding(
      padding: EdgeInsets.all(10),
      sliver: SliverToBoxAdapter(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _PinnedOrders(),
              _OrdersList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IndexScreenState state = ref.watch(indexProvider);
    final Index viewModel = ref.read(indexProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              left: 22,
              top: 22,
              bottom: 10,
            ),
            child: Text(
              "Commandes",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 46,
              border: TableBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              dataTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    overflow: TextOverflow.ellipsis,
                  ),
              headingTextStyle:
                  Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
              showCheckboxColumn: state.showComboBox,
              horizontalMargin: 12,
              dividerThickness: .5,
              onSelectAll: (_) {
                viewModel.selectAll();
              },
              sortColumnIndex: state.sortColumnIndex,
              sortAscending: state.sortAscending,
              columns: Headers.values
                  .map(
                    (e) => DataColumn(
                      label: Text(e.label),
                      numeric: e.isNumeric,
                      headingRowAlignment: MainAxisAlignment.center,
                      onSort: viewModel.sortOrders,
                    ),
                  )
                  .toList(),
              rows: state.orders.map((order) {
                return DataRow(
                  selected: state.selectedOrders.contains(order),
                  onSelectChanged: (bool? value) {
                    if (state.showComboBox) {
                      viewModel.selectOrder(order);
                    } else {
                      if (context.mounted) {
                        context.pushNamed(
                          'order-details',
                          pathParameters: {'orderId': order.id},
                          extra: order,
                        );
                      }
                    }
                  },
                  cells: [
                    DataCell(
                      Hero(
                        tag: 'order-${order.id}',
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            child: Text(
                              order.clientContact,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: StatusCard(
                          status: order.status,
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(order.shopName),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(order.startDate.toDDMMYYYY()),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text(order.endDate?.toDDMMYYYY() ?? ""),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text("${order.price}€"),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: Text("${order.commission}€"),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          onPressed: () {
                            if (context.mounted) {
                              context.pushNamed(
                                'order-details',
                                pathParameters: {'orderId': order.id},
                                extra: order,
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_new),
                          tooltip: "Ouvrir",
                        ),
                      ),
                    ),
                    DataCell(
                      Center(
                        child: IconButton(
                          onPressed: () {
                            viewModel.pinOrder(order);
                          },
                          icon: Icon(
                            state.pinnedOrders.contains(order)
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                          ),
                          tooltip: "Épingler",
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeHeader extends ConsumerWidget {
  const _ResumeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final IndexScreenState state = ref.watch(indexProvider);
    final currentMonth = DateTime.now().month;

    return SliverPadding(
      padding: const EdgeInsets.all(10),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                width: 250,
                height: 100,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Prochaine action"),
                    const SizedBox(height: 10),
                    Text(
                      state.nextActionDate?.toDDMMYYYY() ?? "",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 250,
                height: 100,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total"),
                    const SizedBox(height: 10),
                    Text(
                      "${state.allOrder.fold(
                            0,
                            (sum, order) =>
                                (sum.toDouble() + order.commission).toInt(),
                          ).toStringAsFixed(2)} €",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 250,
                height: 100,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total du mois de $currentMonth"),
                    const SizedBox(height: 10),
                    Text(
                      "${state.allOrder
                          .where(
                              (order) => order.startDate.month == currentMonth)
                          .fold(
                            0,
                            (sum, order) =>
                                (sum.toDouble() + order.commission).toInt(),
                          )
                          .toStringAsFixed(2)} €",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Management bar
class _ManagementBar extends ConsumerWidget {
  /// Constructor
  const _ManagementBar();

  /// Builds the management bar
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(indexProvider);
    final viewModel = ref.read(indexProvider.notifier);

    return SliverPadding(
      padding: const EdgeInsets.all(10),
      sliver: SliverToBoxAdapter(
        child: Align(
          alignment: Alignment.centerRight,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: viewModel.showComboBox,
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    child:
                        Text(state.showComboBox ? "Masquer" : "Sélectionner"),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.add,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
                    label: const Text("Ajouter"),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      foregroundColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.primary,
                      iconColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (state.selectedOrders.isNotEmpty)
                    TextButton.icon(
                      onPressed: viewModel.deleteSelectedOrders,
                      icon: const Icon(Icons.delete),
                      label: const Text("Supprimer"),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
