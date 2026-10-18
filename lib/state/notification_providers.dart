import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart' hide Provider;
import '../data/repositories/notification_repository.dart';
import 'app_providers.dart';

final notificationRepoProvider = Provider<NotificationRepository>(
    (ref) => NotificationRepository(ref.watch(dbProvider)));

final notificationsListProvider = StreamProvider<List<Notification>>(
    (ref) => ref.watch(notificationRepoProvider).watchLatest());

final unreadCountProvider = StreamProvider<int>(
    (ref) => ref.watch(notificationRepoProvider).watchUnreadCount());
