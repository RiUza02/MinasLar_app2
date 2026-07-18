import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Errors/exceptions.dart';

/// [uso] Armazena os dados processados de um endereço para o traçado do mapa.
class RouteStop {
  final String name;
  final double latitude;
  final double longitude;

  RouteStop({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

/// [uso] Coordena a conversão de endereços, otimização de paradas e abertura do GPS externo.
class RouteCalculator {
  /// [uso] Orquestra o fluxo completo da rota a partir de uma lista de orçamentos do dia.
  Future<void> optimizeAndOpenRoute(
    List<Map<String, dynamic>> budgetStops,
  ) async {
    if (budgetStops.isEmpty) {
      throw const ValidationException("Não há orçamentos para traçar rota.");
    }

    // Obtém o ponto de partida do técnico baseado no hardware do GPS.
    final startPoint = await _getCurrentLocation();

    // Converte os textos de endereço dos orçamentos em coordenadas geográficas paralelas.
    final List<Future<RouteStop?>> geocodingFutures = budgetStops.map((
      item,
    ) async {
      final address =
          "${item['rua']}, ${item['numero']} - ${item['bairro']}, ${item['cidade']}";
      try {
        // [uso] Instancia o plugin para acessar a API nativa de geocodificação do dispositivo.
        List<Location> locations = await Geocoding().locationFromAddress(
          address,
        );
        if (locations.isNotEmpty) {
          return RouteStop(
            name: item['nome_cliente'] ?? 'Cliente',
            latitude: locations.first.latitude,
            longitude: locations.first.longitude,
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint("Erro de geocodificação para $address: $e");
        }
      }
      return null;
    }).toList();

    // Aguarda a resposta de todas as requisições de coordenadas e filtra as válidas.
    final results = await Future.wait(geocodingFutures);
    final stops = results.whereType<RouteStop>().toList();

    if (stops.isEmpty) {
      throw const ValidationException(
        "Nenhum endereço válido foi encontrado para a rota.",
      );
    }

    // Executa a ordenação lógica por proximidade física.
    final orderedRoute = _sortByProximity(startPoint, stops);

    // Estrutura o link parametrizado e solicita a abertura do app nativo do Google Maps.
    final url = _buildGoogleMapsUrl(startPoint, orderedRoute);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw const LocationException(
        "Não foi possível abrir o aplicativo de mapas.",
      );
    }
  }

  /// [uso] Applies the Nearest Neighbor algorithm to sort stops by shortest physical distance.
  List<RouteStop> _sortByProximity(
    Position origin,
    List<RouteStop> unorderedList,
  ) {
    final finalRoute = <RouteStop>[];
    final pending = List<RouteStop>.from(unorderedList);

    var currentLat = origin.latitude;
    var currentLng = origin.longitude;

    while (pending.isNotEmpty) {
      RouteStop? nearest;
      var shortestDistance = double.infinity;

      for (final point in pending) {
        // [uso] Mede a distância em metros em linha reta entre dois pontos geográficos.
        final distance = Geolocator.distanceBetween(
          currentLat,
          currentLng,
          point.latitude,
          point.longitude,
        );

        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearest = point;
        }
      }

      if (nearest != null) {
        finalRoute.add(nearest);
        pending.remove(nearest);
        currentLat = nearest.latitude;
        currentLng = nearest.longitude;
      } else {
        break; // Evita travamento por loop infinito em caso de dados corrompidos.
      }
    }
    return finalRoute;
  }

  /// [uso] Formata a URI baseada na API de Directions do Google Maps, incluindo os waypoints intermediários.
  Uri _buildGoogleMapsUrl(Position origin, List<RouteStop> route) {
    final strOrigin = "${origin.latitude},${origin.longitude}";
    final finalDestination = route.last;
    final strDestination =
        "${finalDestination.latitude},${finalDestination.longitude}";

    var strWaypoints = "";
    if (route.length > 1) {
      final waypoints = route.sublist(0, route.length - 1);
      strWaypoints =
          "&waypoints=${waypoints.map((p) => "${p.latitude},${p.longitude}").join("|")}";
    }

    return Uri.parse(
      "https://www.google.com/maps/dir/?api=1&origin=$strOrigin&destination=$strDestination$strWaypoints&travelmode=driving",
    );
  }

  /// [uso] Verifica o status do hardware de localização e solicita permissões de uso ao sistema operacional.
  Future<Position> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('O serviço de GPS está desativado.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException('A permissão de localização foi negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Permissão negada permanentemente. Habilite nas configurações.',
      );
    }

    return Geolocator.getCurrentPosition();
  }
}
