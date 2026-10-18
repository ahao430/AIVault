import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart' hide Provider;
import '../data/repositories/ssh_host_repository.dart';
import '../services/ssh_service.dart';
import 'app_providers.dart';

final sshHostRepoProvider = Provider<SshHostRepository>((ref) =>
    SshHostRepository(ref.watch(dbProvider), ref.watch(secureStoreProvider)));

final sshServiceProvider = Provider<SshService>(
    (ref) => SshService(ref.watch(dbProvider), ref.watch(secureStoreProvider)));

final sshHostsProvider = StreamProvider<List<SshHost>>(
    (ref) => ref.watch(sshHostRepoProvider).watchHosts());
