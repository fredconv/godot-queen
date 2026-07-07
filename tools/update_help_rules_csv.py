#!/usr/bin/env python3
"""Met à jour translations/table.csv avec le texte de docs/regles-de-jeu/regles_dame-de-pique_short.md."""
from __future__ import annotations

import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CSV_PATH = ROOT / "translations" / "table.csv"
LOCALES = ["fr", "en", "de", "es", "pt", "zh"]

FR = """[b]But :[/b] avoir le moins de points possible.

[b]Points :[/b]
• ❤️ = 1 point chacun.
• ♠️ Dame = 13 points.

[b]Déroulement :[/b]
• 4 joueurs, 13 cartes chacun.
• Le 2♣ commence.
• Il faut toujours suivre la couleur si possible.
• Sinon, on joue n'importe quelle carte.
• La plus forte carte de la couleur demandée remporte le pli et récupère toutes les cartes.

[b]Cœurs :[/b]
• On ne peut pas commencer un pli avec un cœur tant qu'un cœur n'a pas déjà été joué (sauf si on n'a plus que des cœurs).

[b]Fin de manche :[/b]
• Chacun compte les points contenus dans ses plis.
• Si un joueur prend tous les cœurs + la Dame de Pique (26 points), il « fait la lune » : les autres prennent généralement 26 points et lui 0.

[b]Fin de partie :[/b]
• Quand un joueur atteint 100 points (ou le score fixé au départ), le joueur ayant le moins de points gagne."""

EN = """[b]Goal:[/b] score as few points as possible.

[b]Points:[/b]
• ❤️ = 1 point each.
• ♠️ Queen = 13 points.

[b]Play:[/b]
• 4 players, 13 cards each.
• 2♣ leads.
• You must follow suit when possible.
• Otherwise, play any card.
• The highest card of the led suit wins the trick and takes all cards.

[b]Hearts:[/b]
• You cannot lead a heart until a heart has been played (unless you only have hearts).

[b]End of hand:[/b]
• Each player counts points in their tricks.
• If a player takes all hearts + the Queen of Spades (26 points), they "shoot the moon": the others usually get 26 points and they get 0.

[b]End of match:[/b]
• When a player reaches 100 points (or the agreed target), the player with the fewest points wins."""

DE = """[b]Ziel:[/b] so wenig Punkte wie möglich sammeln.

[b]Punkte:[/b]
• ❤️ = 1 Punkt je Karte.
• ♠️ Dame = 13 Punkte.

[b]Ablauf:[/b]
• 4 Spieler, je 13 Karten.
• Die Kreuz-2 beginnt.
• Bedienen ist Pflicht, wenn möglich.
• Sonst darf jede Karte gespielt werden.
• Die höchste Karte der angespielten Farbe gewinnt den Stich und nimmt alle Karten.

[b]Herzen:[/b]
• Herzen dürfen nicht angespielt werden, bevor ein Herz gespielt wurde (außer man hat nur Herzen).

[b]Stich-Ende:[/b]
• Jeder zählt die Punkte in seinen Stichen.
• Nimmt ein Spieler alle Herzen + die Pik-Dame (26 Punkte), "schießt er den Mond": die anderen bekommen meist 26 Punkte, er 0.

[b]Spielende:[/b]
• Bei 100 Punkten (oder vereinbartem Ziel) gewinnt der Spieler mit den wenigsten Punkten."""

ES = """[b]Objetivo:[/b] conseguir la menor puntuación posible.

[b]Puntos:[/b]
• ❤️ = 1 punto cada uno.
• ♠️ Dama = 13 puntos.

[b]Desarrollo:[/b]
• 4 jugadores, 13 cartas cada uno.
• Empieza el 2♣.
• Hay que seguir el palo si es posible.
• Si no, se puede jugar cualquier carta.
• La carta más alta del palo pedido gana la baza y se lleva todas las cartas.

[b]Corazones:[/b]
• No se puede empezar una baza con corazón hasta que se haya jugado uno (salvo que solo queden corazones).

[b]Fin de mano:[/b]
• Cada uno cuenta los puntos de sus bazas.
• Si un jugador se lleva todos los corazones + la Dama de picas (26 puntos), "se lleva la luna": los demás suelen recibir 26 puntos y él 0.

[b]Fin de partida:[/b]
• Al llegar a 100 puntos (o la meta acordada), gana quien tenga menos puntos."""

PT = """[b]Objetivo:[/b] fazer o menor número de pontos possível.

[b]Pontos:[/b]
• ❤️ = 1 ponto cada.
• ♠️ Dama = 13 pontos.

[b]Desenvolvimento:[/b]
• 4 jogadores, 13 cartas cada.
• O 2♣ começa.
• É obrigatório seguir o naipe quando possível.
• Caso contrário, pode jogar qualquer carta.
• A carta mais alta do naipe pedido ganha a vaza e fica com todas as cartas.

[b]Copas:[/b]
• Não se pode iniciar uma vaza com copas até que uma copa tenha sido jogada (salvo se só restarem copas).

[b]Fim da mão:[/b]
• Cada um conta os pontos das suas vazas.
• Se um jogador levar todas as copas + a Dama de espadas (26 pontos), "leva a lua": os outros costumam receber 26 pontos e ele 0.

[b]Fim da partida:[/b]
• Ao atingir 100 pontos (ou a meta combinada), vence quem tiver menos pontos."""

ZH = """[b]目标：[/b] 尽量少得分。

[b]计分：[/b]
• ❤️ 每张 1 分。
• ♠️ Q 为 13 分。

[b]流程：[/b]
• 4 名玩家，每人 13 张牌。
• 由梅花 2 先出。
• 有同花色必须跟牌。
• 否则可出任意牌。
• 领出花色中最大的牌赢得该墩并收走所有牌。

[b]红心：[/b]
• 在有人出过红心之前不能领出红心（除非只剩红心）。

[b]一轮结束：[/b]
• 每人统计自己墩中的罚分。
• 若一人收齐全部红心 + 黑桃 Q（26 分），即“收月”：其他人通常各得 26 分，该玩家得 0 分。

[b]对局结束：[/b]
• 当有人达到 100 分（或约定目标）时，得分最少者获胜。"""

TITLES = {
    "fr": "Dame de Pique – Règles express",
    "en": "Hearts – Quick Rules",
    "de": "Herz – Kurzregeln",
    "es": "Corazones – Reglas rápidas",
    "pt": "Copas – Regras rápidas",
    "zh": "红心 – 简要规则",
}

BODIES = {"fr": FR, "en": EN, "de": DE, "es": ES, "pt": PT, "zh": ZH}


def main() -> None:
    rows = list(csv.reader(CSV_PATH.read_text(encoding="utf-8").splitlines()))
    new_rows: list[list[str]] = []
    for row in rows:
        if not row:
            continue
        key = row[0]
        if key in {"TB_HELP_RULE_1", "TB_HELP_RULE_2", "TB_HELP_RULE_3", "TB_HELP_RULE_4"}:
            continue
        if key == "TB_HELP_TITLE":
            row = ["TB_HELP_TITLE", *[TITLES[locale] for locale in LOCALES]]
        new_rows.append(row)

    insert_at = next(i for i, row in enumerate(new_rows) if row[0] == "TB_HELP_TITLE") + 1
    new_rows.insert(
        insert_at,
        ["TB_HELP_RULES_BODY", *[BODIES[locale] for locale in LOCALES]],
    )

    with CSV_PATH.open("w", encoding="utf-8", newline="") as handle:
        csv.writer(handle, lineterminator="\n").writerows(new_rows)

    print(f"Updated {CSV_PATH}")


if __name__ == "__main__":
    main()
