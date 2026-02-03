import 'package:flutter/material.dart';

class Recommendation {
  final IconData icon;
  final String category;
  final String prompt;
  final String porQue;
  final List<String> evitar;
  final List<String> inspiracion;

  const Recommendation({
    required this.icon,
    required this.category,
    required this.prompt,
    required this.porQue,
    required this.evitar,
    required this.inspiracion,
  });
}

final Map<String, List<Recommendation>> recommendations = {
  'menstrual': [
    Recommendation(
      icon: Icons.home,
      category: 'Presencia',
      prompt: 'Ofrécele compañía sin presión',
      porQue:
          'La energía está en mínimos. El dolor físico amplifica la ansiedad. Tu presencia tranquila vale más que mil palabras.',
      evitar: [
        "'Ya va a pasar'",
        "'No es para tanto'",
        "Intentar animarla forzadamente",
        "Proponerle salir o hacer ejercicio"
      ],
      inspiracion: [
        "¿Quieres que me quede contigo?",
        "Ofrece algo concreto: un té, una manta, su serie favorita",
        "Si quiere estar sola, respétalo sin tomártelo personal"
      ],
    ),
    Recommendation(
      icon: Icons.favorite,
      category: 'Validación',
      prompt: 'Reconoce cómo se siente sin minimizar',
      porQue:
          'Las personas con ansiedad suelen sentir culpa por "no estar bien". Validar reduce esa carga.',
      evitar: [
        "'Deberías sentirte mejor'",
        "'Piensa positivo'",
        "Comparar su dolor con el de otros"
      ],
      inspiracion: [
        "Sé que no te sientes bien, no tienes que fingir que sí",
        "Es completamente normal sentirse así",
        "No tienes que explicar por qué te sientes así"
      ],
    ),
  ],
  'follicular': [
    Recommendation(
      icon: Icons.star,
      category: 'Reconocimiento',
      prompt: 'Felicítala por algo que logró recientemente',
      porQue:
          'El estrógeno sube y mejora el ánimo. Es el momento ideal para amplificar su confianza reconociendo logros concretos.',
      evitar: [
        "Cumplidos genéricos sin detalle",
        "Solo elogiar apariencia física"
      ],
      inspiracion: [
        "Menciona algo concreto: un proyecto, una conversación difícil que manejó bien",
        "Me encanta cómo resolviste [situación]",
        "Reconoce el esfuerzo, no solo el resultado"
      ],
    ),
    Recommendation(
      icon: Icons.lightbulb,
      category: 'Propuestas',
      prompt: 'Propón algo nuevo para hacer juntos',
      porQue:
          'Su energía está subiendo y puede estar más receptiva a nuevas ideas y planes.',
      evitar: [
        "Presionarla si no está de ánimo",
        "Propuestas demasiado demandantes"
      ],
      inspiracion: [
        "¿Te gustaría que probemos ese restaurante nuevo?",
        "He estado pensando que podríamos...",
        "Tengo una idea para el fin de semana"
      ],
    ),
  ],
  'ovulation': [
    Recommendation(
      icon: Icons.star,
      category: 'Admiración',
      prompt: 'Dile algo específico que te gusta de ella',
      porQue:
          'Está en pico de confianza. Los cumplidos específicos tienen más impacto que los genéricos.',
      evitar: [
        "Lo genérico: 'eres linda'",
        "Cumplidos que parezcan automáticos"
      ],
      inspiracion: [
        "Me encanta cuando [algo específico que hace]",
        "Menciona algo que notaste y otros no",
        "Valora algo de su carácter"
      ],
    ),
    Recommendation(
      icon: Icons.celebration,
      category: 'Celebración',
      prompt: 'Celebra sus cualidades únicas',
      porQue:
          'En esta fase puede recibir mejor los reconocimientos más elaborados.',
      evitar: [
        "Exagerar al punto de parecer falso",
        "Comparar con otras personas"
      ],
      inspiracion: [
        "Admiro mucho cómo manejas [situación]",
        "Eres increíble cuando...",
        "Lo que más me gusta de ti es..."
      ],
    ),
  ],
  'luteal_early': [
    Recommendation(
      icon: Icons.favorite,
      category: 'Afirmación',
      prompt: 'Recuérdale que está haciendo un gran trabajo',
      porQue:
          'La energía baja y la autocrítica sube. Necesita escuchar que lo que hace es suficiente.',
      evitar: [
        "'Deberías hacer más'",
        "Minimizar sus preocupaciones",
        "'No te preocupes por eso'"
      ],
      inspiracion: [
        "Estás manejando todo increíblemente bien",
        "No tienes que ser perfecta para ser increíble",
        "Reconoce el esfuerzo diario de manejar ansiedad"
      ],
    ),
    Recommendation(
      icon: Icons.self_improvement,
      category: 'Paciencia',
      prompt: 'Demuestra paciencia extra con ella',
      porQue:
          'Puede estar más irritable o sensible. Tu paciencia será un ancla.',
      evitar: [
        "Señalar que está de mal humor",
        "Tomarte personal sus reacciones"
      ],
      inspiracion: [
        "Estoy aquí, sin prisa",
        "Tómate el tiempo que necesites",
        "No hay problema, lo resolvemos juntos"
      ],
    ),
  ],
  'luteal_late': [
    Recommendation(
      icon: Icons.shield,
      category: 'Validación total',
      prompt: 'Valida TODO lo que siente sin intentar arreglarlo',
      porQue:
          'MAYOR vulnerabilidad del ciclo. La ansiedad y depresión se amplifican. Tu trabajo NO es solucionar, es ACOMPAÑAR.',
      evitar: [
        "'Piensa positivo'",
        "'Otros están peor'",
        "'Tranquilízate'",
        "'Son tus hormonas' (invalida)",
        "CUALQUIER intento de 'arreglar' sus emociones"
      ],
      inspiracion: [
        "Estoy aquí. No necesito que estés bien para quererte",
        "Lo que sientes importa, aunque no puedas explicarlo",
        "A veces solo escuchar sin responder es lo más poderoso"
      ],
    ),
    Recommendation(
      icon: Icons.favorite,
      category: 'No eres una carga',
      prompt: 'Dile que NO es "demasiado" ni una carga para ti',
      porQue:
          'Ansiedad + PMS = sentir que es una carga. Este miedo es de los más dolorosos. Necesita certeza.',
      evitar: [
        "'No seas tonta' si expresa esto",
        "Minimizar su miedo",
        "Frustrarte por repetirlo"
      ],
      inspiracion: [
        "Nunca serás demasiado para mí",
        "No eres una carga. Yo elegí estar aquí",
        "Tus días difíciles no me alejan, me acercan"
      ],
    ),
    Recommendation(
      icon: Icons.home,
      category: 'Presencia incondicional',
      prompt: 'Ofrece estar ahí sin condiciones ni expectativas',
      porQue:
          'En los peores días, saber que alguien está ahí es lo único que ayuda.',
      evitar: [
        "Frustrarte si no puede/quiere hablar",
        "Tomarlo personal",
        "Presionar para que 'se abra'"
      ],
      inspiracion: [
        "No tienes que hablar. Solo quiero que sepas que estoy aquí",
        "Podemos sentarnos juntos sin decir nada",
        "Un abrazo largo dice más que cualquier palabra"
      ],
    ),
    Recommendation(
      icon: Icons.wb_sunny,
      category: 'Perspectiva gentil',
      prompt: 'Con delicadeza, recuérdale que los días difíciles pasan',
      porQue:
          'En medio de la crisis es difícil ver más allá. Solo funciona si es GENTIL.',
      evitar: [
        "'Ya se te va a pasar' (dismissive)",
        "'Mañana estarás bien'",
        "Poner fecha a su mejoría"
      ],
      inspiracion: [
        "Sé que ahora se siente eterno, pero has salido de días así antes",
        "No tienes que creerlo ahora, pero yo sé que eres fuerte",
        "Mañana puede ser un poco mejor, y si no, también está bien"
      ],
    ),
    Recommendation(
      icon: Icons.spa,
      category: 'Autocuidado',
      prompt: 'Sugiérele algo reconfortante sin presionarla',
      porQue:
          'La ansiedad puede hacer que se olvide de cuidarse. Sugerir sin imponer es amor.',
      evitar: [
        "'Deberías hacer ejercicio'",
        "'Si comieras mejor...'",
        "Cualquier 'deberías'"
      ],
      inspiracion: [
        "¿Quieres que te prepare un baño caliente?",
        "¿Te pongo tu playlist favorita?",
        "Encárgate de responsabilidades para que descanse"
      ],
    ),
  ],
};
