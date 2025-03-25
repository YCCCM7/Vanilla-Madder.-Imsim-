//=============================================================================
// ThrownProjectile.
//=============================================================================
class ThrownProjectile extends DeusExProjectile
	abstract;

var() float				Elasticity;
var() float				fuseLength;
var() class<Fragment>	FragmentClass;
var() bool				bProximityTriggered;
var() float				proxRadius;
var() bool				bArmed;
var bool				bFirstHit;
var float				proxCheckTime;
var float				beepTime;
var float				skillTime;
var float				skillAtSet;
var() bool				bDisabled;
var() bool				bHighlight;			// should this object not highlight when focused?
var() float				AISoundLevel;		// sound level at which to alert AI (0.0 to 1.0)
var() bool           bDamaged;         // was this blown up via damage?

var bool bDoExplode;		// Used for communication into a simulated chain
var int	team;				// Keep track of team of owner

var bool bSupportingBase;
var float SupportedBaseTime;

replication 
{
	reliable if ( Role == ROLE_Authority )
		bDoExplode, team, bDisabled, skillAtSet;
}

//
// The player won't hear these unless their outisde the simulated function
//
function PlayBeepSound( float Range, float Pitch, float volume )
{
	if ( Level.NetMode != NM_Standalone )
		PlaySound( sound'Beep4',SLOT_None, volume,, Range, Pitch );
	else
		PlaySound( sound'Beep4',SLOT_None,,, Range, Pitch );
}

simulated function Tick(float deltaTime)
{
	local ScriptedPawn P;
	local DeusExPlayer Player;
	local Vector dist, HitLocation, HitNormal;
	local float blinkRate, mult, skillDiff;
	local float proxRelevance;
	local Pawn curPawn;
	local bool pass;
	local Actor HitActor;
	
	local Actor A, TSupported;
	local float DetectMath, Volume;
	local bool bTransCheck;
	
	time += deltaTime;
	
	if ( Role == ROLE_Authority )
	{
		Super.Tick(deltaTime);

		if (bDisabled)
			return;
		
		if ( (Owner == None) && ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
		{
			// Owner has logged out
			bDisabled = True;
			team = -1;
		}
		
		if (( Owner != None ) && (DeusExPlayer(Owner) != None ))
		{
			if ( TeamDMGame(DeusExPlayer(Owner).DXGame) != None )
			{
				// If they switched sides disable the grenade
				if ( DeusExPlayer(Owner).PlayerReplicationInfo.team != team )
				{
					bDisabled = True;
					team = -1;
				}
			}
		}
		
		// check for proximity
		if (bProximityTriggered)
		{
			if (bSupportingBase)
			{
				foreach BasedActors(class'Actor', TSupported)
				{
					if (TSupported.Base == Self)
					{
						break;
					}
				}
				
				if (TSupported != None)
				{
					SupportedBaseTime += DeltaTime;
					if (SupportedBaseTime > 0.25)
					{
						bSupportingBase = false;
						SupportedBaseTime = -9999;
						
						Volume = 0.5+FRand()*0.5;
						PlaySound(MiscSound, SLOT_None, volume,, 512, (0.85+(FRand()*0.3))*VMDGetMiscPitch2());
						
						// I know this is a little cheesy, but certain grenade types should
						// not alert AIs unless they are really really close - CNN
						if (AISoundLevel > 0.0)
						{
							AISendEvent('LoudNoise', EAITYPE_Audio, volume, AISoundLevel*256);
						}
						
						if (DeusExMover(Base) != None)
						{
							SetPhysics(Default.Physics, None);
						}
						else
						{
							SetPhysics(Default.Physics);
						}
						
						RotationRate.Yaw = RotationRate.Yaw * 9;
						RotationRate.Pitch = RotationRate.Pitch * 9;
						RotationRate.Roll = RotationRate.Roll * 9;
						if (Region.Zone != None)
						{
							Velocity = Region.Zone.ZoneGravity * 0.35;
						}
						
						foreach BasedActors(class'Actor', A)
						{
							if (A.Base == Self)
							{
								A.SetBase(None);
							}
						}
					}
				}
				else
				{
					bSupportingBase = false;
				}
			}
			
			if (bArmed)
			{
				proxCheckTime += deltaTime;

				// beep based on skill
				if (skillTime != 0)
				{
					if (time > fuseLength)
					{
						if (skillTime % 0.3 > 0.25)
							PlayBeepSound( 1280, 2.0*VMDGetMiscPitch2(), 3.0 );
					}
				}

				// if we have been triggered, count down based on skill
				if (skillTime > 0)
					skillTime -= deltaTime;

				// explode if time < 0
				if (skillTime < 0)
				{
					bDoExplode = True;
					bArmed = False;
				}
				// DC - new ugly way of doing it - old way was "if (proxCheckTime > 0.25)"
				// new way: weight the check frequency based on distance from player
				proxRelevance=DistanceFromPlayer/2000.0;  // at 500 units it behaves as it did before
				if (proxRelevance<0.25)
					proxRelevance=0.25;               // low bound 1/4
				else if (proxRelevance>10.0)
					proxRelevance=20.0;               // high bound 30
				else
					proxRelevance=proxRelevance*2;    // out past 1.0s, double the timing
				if (proxCheckTime>proxRelevance)
				{
					proxCheckTime = 0;

					// pre-placed explosives are only prox triggered by the player
					if (Owner == None)
					{
						foreach RadiusActors(class'DeusExPlayer', Player, proxRadius*4)
						{
							//MADDERS, 3/10/21: Thanks DXT, gonna yoink that radar trans, too.
							bTransCheck = false;
							if ((Player != None) && (Player.AugmentationSystem != None))
							{
            							if (player.AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') != -1.0)
								{
               								bTransCheck = true;
	  							}
							}
							
							// the owner won't set it off, either
							//MADDERS: Invisible cheat disables mine detonation now.
							if ((Player != Owner) && (Player.bDetectable) && (!bTransCheck))
							{
								dist = Player.Location - Location;
								if ((VSize(dist) < proxRadius) && (FastTrace(Location, Player.Location)))
								{
									if (skillTime == 0)
									{
										DetectMath = VMDGetSkillLevel(Player);
										//MADDERS: Hideous, nasty, ugly tweaks for skill levels and scaling them down.
										if (Abs(DetectMath) <= 0.5)
										{
											DetectMath /= 1.5625;
										}
										
										if ((VMDBufferPlayer(Player) != None) && (!VMDBufferPlayer(Player).HasSkillAugment('DemolitionMineHandling')))
										{
											skillTime = FClamp(-5.0 * DetectMath, 0.5, 5.0);
										}
										else
										{
											skillTime = FClamp(-20.0 * DetectMath, 0.5, 5.0);
										}
									}
								}
							}
						}
					}
					else
					{
						// If in multiplayer, check other players
						if (( Level.NetMode == NM_DedicatedServer) || ( Level.NetMode == NM_ListenServer))
						{
							curPawn = Level.PawnList;

							while ( curPawn != None )
							{
								pass = False;

								if ( curPawn.IsA('DeusExPlayer') )
								{
									Player = DeusExPlayer( curPawn );

									// Pass on owner
									if ( Player == Owner )
										pass = True;
									// Pass on team member
									else if ( (TeamDMGame(Player.DXGame) != None) && (team == player.PlayerReplicationInfo.team) )
										pass = True;
									// Pass if radar transparency on
									else if ( Player.AugmentationSystem.GetClassLevel( class'AugRadarTrans' ) == 3 )
										pass = True;

									// Finally, make sure we can see them (no exploding through thin walls)
									if ( !pass )
									{
										// Only players we can see : changed this to Trace from FastTrace so doors are included
										HitActor = Trace( HitLocation, HitNormal, Player.Location, Location, True );
										if ((HitActor != None ) && (DeusExPlayer(HitActor) != Player))
										{
											pass = True;
										}
									}

									if ( !pass )
									{
										dist = Player.Location - Location;
										if ( VSize(dist) < proxRadius )
										{
											if (skillTime == 0)
											{
												skillDiff = -skillAtSet + VMDGetSkillLevel(Player);
												if ( skillDiff >= 0.0 ) // Scale goes 1.0, 1.6, 2.8, 4.0
													skillTime = FClamp( 1.0 + skillDiff * 6.0, 1.0, 2.5 );
												else	// Scale goes 1.0, 1.4, 2.2, 3.0
													skillTime = FClamp( 1.0	+ (-VMDGetSkillLevel(Player) * 4.0), 1.0, 3.0 );
											}
										}
									}
								}
								curPawn = curPawn.nextPawn;
							}
						}
						else	// Only have scripted pawns set off promixity grenades in single player
						{
							foreach RadiusActors(class'ScriptedPawn', P, proxRadius*4)
							{
								// only "heavy" pawns will set this off
								if ((P != None) && (VMDMegh(P) == None) && (VMDSidd(P) == None) && (P.Mass >= 40) && (FastTrace(P.Location, Location)))
								{
									// the owner won't set it off, either
									if (P != Owner)
									{
										dist = P.Location - Location;
										if (VSize(dist) < proxRadius)
										{
											if (skillTime == 0)
											{
												if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).HasSkillAugment('DemolitionMineHandling')))
												{
													skillTime = 1.0 + (VMDGetSkillLevel(VMDBufferPlayer(Owner)));
												}
												else
												{
													skillTime = 1.0;
												}
											}
										}
									}
								}
							}
						}
					}
				}	
			}
		}

		// beep faster as the time expires
		beepTime += deltaTime;

		if (fuseLength - time <= 0.75)
			blinkRate = 0.1;
		else if (fuseLength - time <= fuseLength * 0.5)
			blinkRate = 0.3;
		else
			blinkRate = 0.5;

		if (time < fuseLength)
		{
			if (beepTime > blinkRate)
			{
				beepTime = 0;
				PlayBeepSound( 1280, 1.0*VMDGetMiscPitch2(), 0.5 );
			}
		}
	}
	if ( bDoExplode )	// Keep the simulated chain going
		Explode(Location, Vector(Rotation));
}							   

//MADDERS: Use this crap for both accessed none elimination and easier access to demolition values.
function float VMDGetSkillLevel(Actor TestPlayer)
{
	local DeusExPlayer DXP;
	
	DXP = DeusExPlayer(TestPlayer);
	if ((DXP != None) && (DXP.SkillSystem != None))
	{
		return DXP.SkillSystem.GetSkillLevelValue(class'SkillDemolition');
	}
	
	return 0.0;
}

function ReEnable()
{
	bDisabled = False;
}

function Frob(Actor Frobber, Inventory frobWith)
{
	// if the player frobs it and it's disabled, the player can grab it
	if (bDisabled)
		Super.Frob(Frobber, frobWith);
	else if (bProximityTriggered && bArmed && (skillTime >= 0))
	{
		// if the player frobs it and has the demolition skill, disarm the explosive
		PlaySound(sound'Beep4',SLOT_None,,, 1280, 0.5*VMDGetMiscPitch());
		bDisabled = True;
	}
}

simulated function Timer()
{
	local Rotator TRot;
	
	if (IsA('C4_Projectile'))
	{
		if ((StuckTo != None) && (!StuckTo.bDeleteMe))
		{
			TRot = (StuckTo.Rotation - StuckToRotation);
			SetRotation(TRot + StickRotation);
			SetLocation(StuckTo.Location + (StickOffset >> TRot));
		}
		else if (bStuckToActor || bStuckToWorld)
		{
			VMDStopSticking();
		}
	}
	else
	{
		if ( Role == ROLE_Authority )
		{
			if (bProximityTriggered)
				bArmed = True;
			else
			{
				if ( !bDisabled )
					bDoExplode = True;
			}
		}
		if ( bDoExplode )
		{
				Explode(Location, Vector(Rotation));
		}
	}
}

simulated function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name damageType)
{
	local ParticleGenerator gen;
	
	if ((DamageType == 'TearGas') || (DamageType == 'PoisonGas') || (DamageType == 'DrugDamage') || (DamageType == 'Radiation') || (DamageType == 'HalonGas') || (DamageType == 'OwnedHalonGas'))
		return;
	
	if (DamageType == 'NanoVirus')
		return;
	
	if ( Role == ROLE_Authority )
	{
		// EMP damage disables explosives
		if (DamageType == 'EMP' || DamageType == 'Shocked' || DamageType == 'Stunned')
		{
			if (!bDisabled)
			{
				PlaySound(sound'EMPZap', SLOT_None,,, 1280, VMDGetMiscPitch());
				bDisabled = True;
				gen = Spawn(class'ParticleGenerator', Self,, Location, rot(16384,0,0));
				if (gen != None)
				{
					gen.checkTime = 0.25;
					gen.LifeSpan = 2;
					gen.particleDrawScale = 0.3;
					gen.bRandomEject = True;
					gen.ejectSpeed = 10.0;
					gen.bGravity = False;
					gen.bParticlesUnlit = True;
					gen.frequency = 0.5;
					gen.riseRate = 10.0;
					gen.spawnSound = Sound'Spark2';
					gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
					gen.SetBase(Self);
				}
			}
			return;
		}
		bDamaged = True;
	}
	Explode(Location, Vector(Rotation));
}

//
// SpawnTearGas needs to happen on the server so the clouds are insync and damage is dealt out of them
//
function SpawnTearGas()
{
	local Vector loc;
	local TearGas gas;
	local int i;

	if ( Role < ROLE_Authority )
		return;

	for (i=0; i<blastRadius/36; i++)
	{
		if (FRand() < 0.9)
		{
			loc = Location;
			loc.X += FRand() * blastRadius - blastRadius * 0.5;
			loc.Y += FRand() * blastRadius - blastRadius * 0.5;
			loc.Z += 32;
			gas = spawn(class'TearGas', None,, loc);
			if (gas != None)
			{
				gas.Velocity = vect(0,0,0);
				gas.Acceleration = vect(0,0,0);
				gas.DrawScale = FRand() * 0.5 + 2.0;
				gas.LifeSpan = FRand() * 10 + 30;
				if ( Level.NetMode != NM_Standalone )
					gas.bFloating = False;
				else
					gas.bFloating = True;
				gas.Instigator = Instigator;
			}
		}
	}
}

simulated function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other)
{
	local int i;
	local SmokeTrail puff;
	local TearGas gas;
	local Fragment frag;
	local ParticleGenerator gen;
	local ProjectileGenerator projgen;
	local vector loc;
	local rotator rot;
	local ExplosionLight light;
	local DeusExDecal mark;
   	local AnimatedSprite expeffect;

	rot.Pitch = 16384 + FRand() * 16384 - 8192;
	rot.Yaw = FRand() * 65536;
	rot.Roll = 0;

	if ((damageType == 'Exploded') && bStuck)
	{
		gen = spawn(class'ParticleGenerator',,, HitLocation, rot);
		if (gen != None)
		{
         		//DEUS_EX AMSD Don't send this to clients unless really spawned server side.
         		if (bDamaged)
			{
            			gen.RemoteRole = ROLE_SimulatedProxy;
			}
        		else
			{
   				gen.RemoteRole = ROLE_None;
			}
			
			gen.LifeSpan = FRand() * 10 + 10;
			gen.CheckTime = 0.25;
			gen.particleDrawScale = 0.4;
			gen.RiseRate = 20.0;
			gen.bRandomEject = True;
			gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
		}
	}

	// don't draw damage art on destroyed movers
	if (DeusExMover(Other) != None)
		if (DeusExMover(Other).bDestroyed)
			ExplosionDecal = None;

	if (ExplosionDecal != None)
	{
		mark = DeusExDecal(Spawn(ExplosionDecal, Self,, HitLocation, Rotator(HitNormal)));
		if (mark != None)
		{
			mark.DrawScale = FClamp(damage/30, 0.1, 3.0);
			mark.ReattachDecal();
         		if (!bDamaged)
            			mark.RemoteRole = ROLE_None;
		}
	}

	for (i=0; i<blastRadius/36; i++)
	{
		if (FRand() < 0.9)
		{
			if (bDebris && bStuck)
			{
				frag = spawn(FragmentClass,,, HitLocation);
				if (!bDamaged)
					frag.RemoteRole = ROLE_None;
				if (frag != None)
					frag.CalcVelocity(VRand(), blastRadius);
			}

			loc = Location;
			loc.X += FRand() * blastRadius - blastRadius * 0.5;
			loc.Y += FRand() * blastRadius - blastRadius * 0.5;

			if (damageType == 'Exploded')
			{
				puff = spawn(class'SmokeTrail',,, loc);
				if (puff != None)
				{
					if (!bDamaged)
						puff.RemoteRole = ROLE_None;
					else					
						puff.RemoteRole = ROLE_SimulatedProxy;
					puff.RiseRate = FRand() + 1;
					puff.DrawScale = FRand() + 3.0;
					puff.OrigScale = puff.DrawScale;
					puff.LifeSpan = FRand() * 10 + 10;
					puff.OrigLifeSpan = puff.LifeSpan;
				}

				light = Spawn(class'ExplosionLight',,, HitLocation);
				if ((light != None) && (!bDamaged))
					light.RemoteRole = ROLE_None;

				if (FRand() < 0.5)
				{
					expeffect = spawn(class'ExplosionSmall',,, loc);
					light.size = 2;
				}
				else
				{
					expeffect = spawn(class'ExplosionMedium',,, loc);
					light.size = 4;
				}
				if ((expeffect != None) && (!bDamaged))
					expeffect.RemoteRole = ROLE_None;
			}
			else if (damageType == 'EMP')
			{
				light = Spawn(class'ExplosionLight',,, HitLocation);
				if (light != None)
				{
					if (!bDamaged)
						light.RemoteRole = ROLE_None;
					light.size = 6;
					light.LightHue = 170;
					light.LightSaturation = 64;
				}
			}
		}
	}
}

function PlayImpactSound()
{
	PlaySound(ImpactSound, SLOT_None, 2.0,, blastRadius*16, VMDGetMiscPitch());
}

auto simulated state Flying
{
	//G-Flex: overloaded from DeusExProjectile so we don't blow up when we hit a corpse
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (Other.IsA('DeusExCarcass'))
			return;
		Super.ProcessTouch(Other, HitLocation);
	}
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local float dist, NoiseMult;
		local DeusExPlayer player;
		local Pawn curPawn;
		local ShockRing ring;

		// flash the screen white based on how far away the explosion is
		
		//== Y|y: we need to do this really complicated to make it work in both single and multiplayer, and to work with EVERYONE's grenades
		//==  Thanks to Lork for pointing out that this was a problem
		if(Level.NetMode == NM_Standalone)
			curPawn = GetPlayerPawn();
		else if (( Level.NetMode == NM_DedicatedServer) || ( Level.NetMode == NM_ListenServer))
			curPawn = Level.PawnList;
		
		while(curPawn != None)
		{
			player = DeusExPlayer(curPawn);

			if (player != None)
				dist = Abs(VSize(player.Location - Location));
			
			// if you are at the same location, blind the player
			if (dist ~= 0)
				dist = 10.0;
			else
				dist = 2.0 * FClamp(blastRadius/dist, 0.0, 4.0);
			
			if (Player != None && ((Human(Player) != None && !Human(Player).bEpilepsyReduction) || Human(Player) == None))
			{
				if (damageType == 'EMP')
					player.ClientFlash(dist, vect(0,200,1000));
				else if (damageType == 'TearGas')
					player.ClientFlash(dist, vect(0,1000,100));
				else
					player.ClientFlash(dist, vect(1000,1000,900));
			}
			
			if(Level.NetMode == NM_Standalone) //== Only one player in singleplayer, so halt the loop
				curPawn = None;
			else //== Cycle through all the remaining players in Multiplayer
				curPawn = curPawn.nextPawn;
		}
      		//DEUS_EX AMSD Only do visual effects if client or if destroyed via damage (since the client can't detect that)
      		if ((Level.NetMode != NM_DedicatedServer) || (Role < ROLE_Authority) || bDamaged)
      		{
         		SpawnEffects(HitLocation, HitNormal, None);
         		DrawExplosionEffects(HitLocation, HitNormal);
      		}
		
		if ((damageType=='TearGas') && (Role==ROLE_Authority))
			SpawnTearGas();
		
		PlayImpactSound();
		
		if ( AISoundLevel > 0.0 )
		{
			NoiseMult = VMDOpenSpaceRadiusMult();
			AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, AISoundLevel*blastRadius*16*NoiseMult);
		}
		
		GotoState('Exploding');
	}
	simulated function HitWall (vector HitNormal, actor HitWall)
	{
		local float volume, NoiseMult;
		local Rotator rot;
		
		if (bSticky)
		{
			VMDStickTo(HitWall);
		}
		else if ((!bStuckToActor) && (!bStuckToWorld))
		{
			// Transcended - Allow grenades to break windows or weak doors
			if ((HitWall.IsA('DeusExMover')) && (speed > 400))
			{
				if (((DeusExMover(HitWall).IsA('BreakableGlass')) || (DeusExMover(HitWall).minDamageThreshold <= 10)) && (DeusExMover(HitWall).bBreakable))
				{
					DeusExMover(HitWall).TakeDamage(speed / 50.00, Instigator, location, 0.1 * Mass * Velocity, 'Exploded');
				}
			}
			
			// Transcended - Do not bounce if crashing through a window		
			if (((HitWall.IsA('DeusExMover')) && (speed > 400)) && (((DeusExMover(HitWall).IsA('BreakableGlass')) || (DeusExMover(HitWall).minDamageThreshold <= 10)) && (DeusExMover(HitWall).bBreakable)))
			{
				return;
			}
			else
			{
				Velocity = Elasticity*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
				speed = VSize(Velocity);	
				if ((bFirstHit) && (speed < 400))
					bFirstHit = False;
				
				RotationRate = RotRand(True);
				if ((speed < 60) && (HitNormal.Z > 0.7))
				{
					volume = 0.5+FRand()*0.5;
					PlaySound(MiscSound, SLOT_None, volume,, 512, (0.85+(FRand()*0.3))*VMDGetMiscPitch2());
					
					// I know this is a little cheesy, but certain grenade types should
					// not alert AIs unless they are really really close - CNN
					if (AISoundLevel > 0.0)
					{
						NoiseMult = VMDOpenSpaceRadiusMult();
						AISendEvent('LoudNoise', EAITYPE_Audio, volume, AISoundLevel*256*NoiseMult);
					}
					
					SetPhysics(PHYS_None, HitWall);
					if (Physics == PHYS_None)
					{
						rot = Rotator(HitNormal);
						rot.Yaw = Rand(65536);
						SetRotation(rot);
						bBounce = False;
							bStuck = True;
					}
				}
				else If (speed > 50) 
				{
					PlaySound(MiscSound, SLOT_None, 0.5+FRand()*0.5,, 512, (0.85+(FRand()*0.3))*VMDGetMiscPitch2());
				}
			}
		}
	}
	//MADDERS, 3/10/21: Last call on this for now, but we're keeping grenade climbing for the time being.
	//To make a return via augment? If I can find room.
	//------------------------
	//MADDERS, 6/18/24: Update... We are now doing this with a difficulty option only.
	event SupportActor( actor StandingActor )
	{
		local float Angle;
		local Vector NewVelocity;
		local VMDBufferPlayer VMP;
		
		if ((VSize(Velocity) > 20) && (SupportedBaseTime < 0))
		{
			angle = FRand()*Pi*2;
			newVelocity.X = cos(angle);
			newVelocity.Y = sin(angle);
			newVelocity.Z = 0;
			newVelocity *= FRand()*25 + 25;
			newVelocity += standingActor.Velocity;
			newVelocity.Z = 50;
			standingActor.Velocity = newVelocity;
			if (ThrownProjectile(StandingActor) == None)
			{
				standingActor.SetPhysics(PHYS_Falling);
			}
		}
		else
		{
			Super.SupportActor(StandingActor);
			
			if ((StandingActor != None) && (ThrownProjectile(StandingActor) == None)) // || VSize(StandingActor.Velocity) > 20
			{
				if ((bStuck) && (Base == None || DeusExMover(Base) != None))
				{
					VMP = VMDBufferPlayer(GetPlayerPawn());
					if ((VMP != None) && (VMP.bWeakGrenadeClimbing) && (!bSupportingBase))
					{
						bSupportingBase = True;
					}
					
					/*
					{
						if (DeusExMover(Base) != None)
							SetPhysics(Default.Physics, None);
						else
							SetPhysics(Default.Physics);
					}*/
				}
				Mass = Default.Mass + StandingActor.Mass;
				Velocity /= 2;
			}
		}
	}
}

simulated singular function ZoneChange( ZoneInfo NewZone )
{
	local float splashsize;
	local actor splash;

	if ( NewZone.bWaterZone )
	{
		Velocity = 0.2 * Velocity;
		splashSize = 0.0005 * (250 - 0.5 * Velocity.Z);
		if ( Level.NetMode != NM_DedicatedServer )
		{
			if ( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_None, splashSize);
			if ( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor); 
				if ( splash != None )
					splash.DrawScale = 4 * splashSize;
			}
		}
		if (bFirstHit) 
			bFirstHit=False;
		
		RotationRate = 0.2 * RotationRate;
	}
}

simulated function BeginPlay()
{
	local DeusExPlayer aplayer;

	Super.BeginPlay();

	Velocity = Speed * Vector(Rotation);
	RotationRate = RotRand(True);
	SetTimer(fuseLength, False);
	SetCollision(True, True, True);

	// What team is the owner if in team game
	if (( Level.NetMode != NM_Standalone ) && (Role == ROLE_Authority))
	{
		aplayer = DeusExPlayer(Owner);
		if (( aplayer != None ) && ( TeamDMGame(aplayer.DXGame) != None ))
			team = aplayer.PlayerReplicationInfo.team;

		if ( aplayer != None )
			skillAtSet = aplayer.SkillSystem.GetSkillLevelValue(class'SkillDemolition');
	}

	// don't beep at the start of a level if we've been preplaced
	if (Owner == None)
	{
		time = fuseLength;
		bStuck = True;
	}
}

defaultproperties
{
     elasticity=0.500000
     fuseLength=5.000000
     FragmentClass=Class'DeusEx.Rockchip'
     proxRadius=64.000000
     bFirstHit=True
     bHighlight=True
     AISoundLevel=1.000000
     bExplodes=True
     bBlood=True
     bDebris=True
     blastRadius=512.000000
     DamageType=exploded
     ItemName="ERROR ThrownProjectile Default-Report as bug!"
     ItemArticle="a"
     ImpactSound=Sound'DeusExSounds.Generic.LargeExplosion1'
     MiscSound=Sound'DeusExSounds.Generic.MetalBounce1'
     Physics=PHYS_Falling
     CollisionRadius=2.000000
     CollisionHeight=2.000000
     bBounce=True
     bFixedRotationDir=True
}
