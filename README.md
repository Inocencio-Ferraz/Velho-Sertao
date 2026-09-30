# Velho Sertão

Uma aventura de ação 2D ambientada no sertão paraibano do início do século XX. Em busca de água, João Grilo atravessa uma paisagem seca, enfrenta cangaceiros e procura os poços de Sousa.

## Sobre o jogo

Velho Sertão está sendo desenvolvido para a GameJam do X SEMITI, no IFPB Campus Monteiro. O protótipo combina exploração top-down, combate simples e uma jornada narrativa inspirada no sertão nordestino e no contexto histórico do cangaço.

O percurso implementado leva o jogador da casa e da igreja ao primeiro poço e, depois, ao segundo. O segundo poço é protegido por quatro cangaceiros; dois deles usam pistolas. O terceiro poço, os dinossauros e o desfecho ainda serão desenvolvidos.

## Informações

- Tema: Velho Sertão
- Engine: Godot 4.7.2
- Linguagem: GDScript
- Gênero: ação e exploração 2D top-down
- Ambientação: sertão nordestino, com referência à Paraíba e ao período do cangaço
- Plataforma principal: desktop/Linux

## Equipe

- Inocencio-Ferraz
- Bruno-arj
- Clebio-Luis

## Estado do protótipo

O projeto inclui movimentação em oito direções, câmera, colisões, HUD de vida e munição, facão, pistola com projétil visível, cangaceiros com perseguição e ataques corpo a corpo ou à distância, cactos de cura de uso único, igreja, Padre com diálogo, dois poços, pausa e tela de Game Over.

O jogador começa com 3 pontos de vida e 6 balas. Cada disparo da pistola causa 15 de dano, tem alcance máximo de 250 px e cooldown de 0,4 s. Cada cangaceiro derrotado fornece 2 balas, sem limite máximo de munição. Cangaceiros armados começam com 3 disparos; seus projéteis causam 1 ponto de dano e respeitam um intervalo mínimo de 3 s.

Os cactos interativos recuperam 1 ponto de vida quando o jogador está ferido. Cada cacto pode ser usado uma vez e não é consumido quando o jogador está com a vida cheia. As teclas H e J são ações temporárias de teste para receber dano e recuperar vida.

## Executar

1. Abra `project.godot` no Godot 4.7.2.
2. Pressione F5 para executar o jogo a partir da cena principal.

## Controles

- W/A/S/D: movimentar
- Mouse esquerdo: atacar com o facão
- Mouse direito: disparar a pistola
- E: interagir com cactos ou avançar o diálogo
- Esc: pausar ou continuar
- H: teste de dano
- J: teste de cura
