enum Palo: String {
  case bastos = "Bastos"
  case copas = "Copas"
  case espadas = "Espadas"
  case oros = "Oros"
}

class Carta {
  let valor: Int
  let palo: Palo

  init?(valor: Int, palo: Palo) {
    if (1...7).contains(valor) || (10...12).contains(valor) {
      self.valor = valor
      self.palo = palo
    } else {
      return nil
    }
  }

  func descripcion() -> String {
    return "El \(valor) de \(palo.rawValue)"
  }
}

class Mano {
  var cartas: [Carta]

  var tamanio: Int {
    return cartas.count
  }

  init() {
    cartas = []
  }

  func addCarta(_ carta: Carta) {
    cartas.append(carta)
  }

  func getCarta(pos: Int) -> Carta? {
    if pos >= 0 && pos < tamanio {
      return cartas[pos]
    }
    return nil
  }

  // Método para calcular la puntuación de la mano
  func calcularPuntuacion() -> Double {
    var puntuacion = 0.0
    var cantidadDeFiguras = 0

    for carta in cartas {
      if (1...7).contains(carta.valor) {
        puntuacion += Double(carta.valor)
      } else {
        cantidadDeFiguras += 1
        puntuacion += 0.5
      }
    }

    // Si la puntuación es igual a 7.5, no se pasa.
    // Si la puntuación es mayor a 7.5, se pierde.
    if puntuacion == 7.5 {
      return puntuacion
    } else if cantidadDeFiguras > 0 {
      // Ajusta la puntuación si hay figuras (sota, caballo, rey).
      // Para no pasarse de 7.5, resta 0.5 por cada figura si la puntuación es mayor a 7.5.
      if puntuacion > 7.5 {
        let ajuste = Double(cantidadDeFiguras) * 0.5
        puntuacion -= ajuste
      }
    }

    return puntuacion
  }
}

class Baraja {
  var cartas: [Carta]

  init() {
    cartas = []
    for palo in [Palo.bastos, Palo.copas, Palo.espadas, Palo.oros] {
      for valor in 1...7 where valor != 8 && valor != 9 {
        if let carta = Carta(valor: valor, palo: palo) {
          cartas.append(carta)
        }
      }
      for valor in 10...12 {
        if let carta = Carta(valor: valor, palo: palo) {
          cartas.append(carta)
        }
      }
    }
  }

  func repartirCarta() -> Carta? {
    return cartas.popLast()
  }

  func barajar() {
    cartas.shuffle()
  }
}

enum EstadoJuego {
  case turnoJugador
  case ganaJugador
  case pierdeJugador
  case empate
  case noIniciado
}

class Juego {
  var baraja: Baraja
  var manoJugador: Mano
  var estado: EstadoJuego
  var jugadaMaquina: Double

  init() {
    baraja = Baraja()
    manoJugador = Mano()
    estado = .noIniciado
    jugadaMaquina = 0.0
  }

  func comenzarPartida() {
    baraja.barajar()
    manoJugador = Mano()
    jugadaMaquina = Double(Int.random(in: 1...7))
    if Bool.random() {
      jugadaMaquina += 0.5
    }
    estado = .turnoJugador
  }

  func jugadorPideCarta() {
    guard estado == .turnoJugador else { // Guard para comprobar si el turno se encuentra en el indicado en la comprobación, si no lo está sale de la función
      return
    }
    if let carta = baraja.repartirCarta() {
      manoJugador.addCarta(carta)
      print("Has recibido una carta: \(carta.descripcion())")
      if manoJugador.tamanio >= 4 {
        jugadorSePlanta()
      }
    }
  }

  func jugadorSePlanta() {
      guard estado == .turnoJugador else {
          return
      }
      acabarPartida()
  }

  private func acabarPartida() {
      // Calcular la puntuación del jugador usando el método de Mano
      let puntuacionJugador = manoJugador.calcularPuntuacion()

      // Calcular quién gana
      if puntuacionJugador > 7.5 {
          estado = .pierdeJugador
      } else if puntuacionJugador > jugadaMaquina || jugadaMaquina > 7.5 {
          estado = .ganaJugador
      } else if puntuacionJugador == jugadaMaquina {
          estado = .empate
      } else {
          estado = .pierdeJugador
      }

      // Imprimir un mensaje
      switch estado {
      case .ganaJugador:
          print("Has ganado. Jugador: \(puntuacionJugador) - Máquina: \(jugadaMaquina)")
      case .pierdeJugador:
          print("Has perdido. Jugador: \(puntuacionJugador) - Máquina: \(jugadaMaquina)")
      case .empate:
          print("Hay empate. Jugador: \(puntuacionJugador) - Máquina: \(jugadaMaquina)")
      default:
          break
      }
  }
}

// Ejemplo (automático)
var juego = Juego()
juego.comenzarPartida()
juego.jugadorPideCarta()
juego.jugadorPideCarta()
juego.jugadorPideCarta()
juego.jugadorPideCarta()
juego.jugadorSePlanta()

