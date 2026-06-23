import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/data/models/cart_item_model.dart';
import 'package:mobile_pos/providers/cart_provider.dart';

void main() {
  group('CartNotifier Tests', () {
    test('adding a new item to cart should add it with the specified quantity', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartNotifier = container.read(cartProvider.notifier);

      cartNotifier.addItem(CartItem(
        productId: 'item1',
        name: 'Item 1',
        priceCents: 100,
        quantity: 3,
      ));

      final state = container.read(cartProvider);
      expect(state.length, 1);
      expect(state[0].productId, 'item1');
      expect(state[0].quantity, 3);
    });

    test('adding an already existing item should sum the new quantity to the existing quantity', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartNotifier = container.read(cartProvider.notifier);

      cartNotifier.addItem(CartItem(
        productId: 'item1',
        name: 'Item 1',
        priceCents: 100,
        quantity: 2,
      ));

      cartNotifier.addItem(CartItem(
        productId: 'item1',
        name: 'Item 1',
        priceCents: 100,
        quantity: 3,
      ));

      final state = container.read(cartProvider);
      expect(state.length, 1);
      expect(state[0].productId, 'item1');
      expect(state[0].quantity, 5);
    });
  });
}
