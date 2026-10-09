import 'package:expenses_repository/expense_repository.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseExpenseRepo implements ExpenseRepository {
  final categoryCollection =
      FirebaseFirestore.instance.collection('categories');

  final expenseCollection = FirebaseFirestore.instance.collection('expenses');

  @override
  Future<void> createCategory(Category category) async {
    try {
      await categoryCollection
          .doc(category.categoryId)
          .set(category.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final snapshot = await categoryCollection.get();
      return snapshot.docs
          .map((e) => Category.fromEntity(CategoryEntity.fromDocument(e.data())))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await categoryCollection.doc(categoryId).delete();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> createExpense(Expense expense) async {
    try {
      await expenseCollection
          .doc(expense.expenseId)
          .set(expense.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpense() async {
    try {
      final snapshot = await expenseCollection.get();
      return snapshot.docs
          .map((e) => Expense.fromEntity(ExpenseEntity.fromDocument(e.data())))
          .toList();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await expenseCollection.doc(expenseId).delete();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteExpensesByCategory(String categoryId) async {
    try {
      final snapshot = await expenseCollection
          .where('category.categoryId', isEqualTo: categoryId)
          .get();
      for (var i = 0; i < snapshot.docs.length; i += 400) {
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs.skip(i).take(400)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> deleteAllExpenses() async {
    try {
      final snapshot = await expenseCollection.get();
      // Firestore batches are limited to 500 operations.
      for (var i = 0; i < snapshot.docs.length; i += 400) {
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs.skip(i).take(400)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
