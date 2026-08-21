Godot Test Project for ARD-GameJam

1.0
----------------
Spieler kann sich bewegen 														done
Spieler kann nicht aus dem Bild laufen											done
Objekte können aufgesammelt werden												done
Ein Gegnertyp 																	done
Bäume																			done
Punktestand (eventuell einfach überlebenszeit?!?)								done
Game Over																		done
Neustart																		done
Pause Overlay																	done
Sound & Musik
Level ist vollständig aufgebaut
Sprites

Reaktionen auf das Thema
----------------
Was ist der Spieler
Was ist der Gegner
Wo spielt es sich ab
Was wird eingesammelt

Szenenaufbau
----------------
Game	(node)
- Systems (node)
-- timer (timer)
- Backgroundlayer	(Canvaslayer) -10
- World	(node2D)
-- LevelRoot	(node2D)
--- Trees	(node2D)
-- EntityRoot	(node2D)
--- Player	(CharacterBody2D) 
--- Enemy (CharacterBody2D)
--- Collectables (node2D)
- PickupSpawner	(Marker2D)
- EnemySpawner	(Marker2D)
- HUD	(Canvaslayer)	10
- PauseOverlay	(Canvaslayer)	50
- GameOverOverlay	(Canvaslayer)	60

Benötigte Sprites 48x48
----------------
Spieler
Enemys
Pickup
Boden
Bäume
UI Icons (nach Game Buttons suchen
- Musik (Musiknote)
- Sound (on/off)
- Resume 
- Restart


Berücksichtigen zur Jam
----------------
Player braucht eine Gruppe "Player"												done
Player im ordering auf 1 setzen													done
Collactables auf ordering 0 setzen												done
Enemies auf ordering 2 setzen													done
im Timeout auf die Effektdauer muss 
ich mit bind arbeiten _on_timer_timeout.bind(var)
Spieler kann Bildschrim nicht verlassen											done
	@onready var screen_size = get_viewport_rect().size
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
