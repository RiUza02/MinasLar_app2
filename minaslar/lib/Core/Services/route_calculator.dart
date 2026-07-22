import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Errors/exceptions.dart';

// **[Propósito]** Armazena os dados georreferenciados de um endereço para compor os waypoints da rota.
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

// **[Propósito]** Coordena a conversão de endereços em coordenadas, otimização da ordem de visitas e abertura do GPS externo.
// **[Como usar]** await RouteCalculator().optimizeAndOpenRoute(listaDeOrcamentos);
class RouteCalculator {
  // **[Propósito]** Orquestra o fluxo completo: obtém GPS atual, geocodifica os endereços, otimiza o trajeto e abre no mapa.
  // **[Parâmetros]** budgetStops (List<Map<String, dynamic>>) -> Lista contendo os dados dos clientes/endereços do dia.
  // **[Como usar]** await routeCalculator.optimizeAndOpenRoute([{'rua': 'Av...', 'numero': '10', 'bairro': 'Centro', 'cidade': 'JF'}]);
  Future<void> optimizeAndOpenRoute(
    List<Map<String, dynamic>> budgetStops,
  ) async {
    if (budgetStops.isEmpty) {
      throw const ValidationException("Não há orçamentos para traçar rota.");
    }

    // Obtém a coordenada geodésica atual do dispositivo via GPS.
    final startPoint = await _getCurrentLocation();

    // Converte os textos de endereço em coordenadas (Latitude/Longitude) em requisições paralelas.
    final List<Future<RouteStop?>> geocodingFutures = budgetStops.map((
      item,
    ) async {
      final address =
          "${item['rua']}, ${item['numero']} - ${item['bairro']}, ${item['cidade']}";
      try {
        // **[Uso]** Aciona a API nativa de geocodificação do sistema operacional para buscar as coordenadas.
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

    // Aguarda o término de todas as conversões e descarta os endereços que não puderam ser localizados.
    final results = await Future.wait(geocodingFutures);
    final stops = results.whereType<RouteStop>().toList();

    if (stops.isEmpty) {
      throw const ValidationException(
        "Nenhum endereço válido foi encontrado para a rota.",
      );
    }

    // Organiza as paradas gerando o percurso físico mais curto baseado na localização atual.
    final orderedRoute = _sortByProximity(startPoint, stops);

    // Monta a URL parametrizada com os waypoints e lança o aplicativo nativo de mapas.
    final url = _buildGoogleMapsUrl(startPoint, orderedRoute);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw const LocationException(
        "Não foi possível abrir o aplicativo de mapas.",
      );
    }
  }

  // **[Propósito]** Aplica o algoritmo "Vizinho Mais Próximo" para ordenar as paradas pela menor distância física percorrida.
  // **[Parâmetros]** origin (Position) -> Ponto inicial do técnico / unorderedList (List<RouteStop>) -> Lista bruta de destinos.
  // **[Retorno]** List<RouteStop> -> Lista reordenada com a sequência otimizada de visitas.
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
        // **[Uso]** Mede a distância em metros (linha reta) entre dois pares de coordenadas geográficas.
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
        break; // Trava de segurança contra loops infinitos caso os cálculos de distância falhem.
      }
    }
    return finalRoute;
  }

  // **[Propósito]** Estrutura a URI no padrão Google Maps Directions API integrando ponto de partida, paradas intermediárias e destino final.
  // **[Parâmetros]** origin (Position) -> Coordenadas de início / route (List<RouteStop>) -> Lista já ordenada de destinos.
  // **[Retorno]** Uri -> Link completo pronto para execução pelo OS.
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

  // **[Propósito]** Valida os serviços de GPS do sistema, solicita permissões se necessário e retorna as coordenadas do dispositivo.
  // **[Retorno]** Future<Position> -> Objeto contendo os dados geográficos atuais da máquina.
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
