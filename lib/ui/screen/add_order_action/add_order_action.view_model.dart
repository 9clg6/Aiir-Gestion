import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:squirrel/application/providers/initializer.dart';
import 'package:squirrel/domain/entities/action.entity.dart';
import 'package:squirrel/domain/service/dialog.service.dart';
import 'package:squirrel/foundation/routing/app_router.dart';
import 'package:squirrel/ui/screen/add_order_action/add_order_action.view_state.dart';

part 'add_order_action.view_model.g.dart';

@riverpod
class AddOrderAction extends _$AddOrderAction {
  late final DialogService _dialogService;

  @override
  AddOrderActionViewState build() {
    _dialogService = injector<DialogService>();
    return AddOrderActionViewState.initial();
  }

  /// Pick date
  ///
  Future<void> pickDate() async {
    final DateTime? selectedDate =
        (await _dialogService.showDatePickerDialog())?.firstOrNull;

    if (selectedDate != null) {
      state = state.copyWith(selectedDate: selectedDate);
    }
  }

  /// Navigate back
  ///
  void navigateBack({OrderAction? result}) {
    appRouter.pop<OrderAction?>(result);
  }

  void navigateBackWithResult() {
    if (state.formKey.currentState?.validate() == false) {
      return;
    }

    navigateBack(
      result: OrderAction(
        date: state.selectedDate!,
        description: state.controller.text,
      ),
    );
  }
}
