# Velho Sertão

Jogo desenvolvido para a GameJam do X SEMITI - IFPB Campus Monteiro.

## Tema

Velho Sertão

## Engine

Godot 4.7.2

## Linguagem

GDScript

## Equipe

- Integrante 1:
- Integrante 2:
- Integrante 3:

## Protótipo atual

Cena de teste top-down com personagem placeholder, movimentação em oito direções, câmera, obstáculos com colisão, HUD de vida e munição, ataque de facão, pistola com seis disparos, cactos de cura de uso único, menu de pausa, igreja e Padre com diálogo, e um Cangaceiro controlado por IA simples.

A vida começa em 3 de 3. As teclas temporárias H (dano) e J (cura) estão marcadas como TESTE na tela. Aproxime-se de um cacto e pressione E para recuperar 1 ponto de vida (cada cacto só cura uma vez; com vida cheia ele não é consumido). Clique com o botão esquerdo para atacar com o facão. Clique com o botão direito para disparar; cada tiro causa 15 de dano, tem alcance de 250 px e usa cooldown de 0,4 s. O Cangaceiro tem 30 de vida, detecta o jogador a até 200 px e ataca corpo a corpo quando está a até 40 px.

## Executar

Abra `project.godot` no Godot 4.7.2 e pressione F6 para executar a cena atual ou F5 para iniciar o projeto.

## Controles

- W/A/S/D: mover
- H: TESTE — receber 1 de dano
- J: TESTE — recuperar 1 de vida
- E: interagir com cacto próximo / avançar diálogo com o Padre
- Esc: pausar/continuar
- Mouse esquerdo: facão (alcance curto; cooldown de 0,4 s)
- Mouse direito: pistola (6 tiros; sem recarga)
