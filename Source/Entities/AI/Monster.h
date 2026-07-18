#pragma once
#include "Leadwerks.h"
#include "Enemy.h"

using namespace Leadwerks;

class Monster : public Enemy//Component
{
    bool attackfinished = false;
public: 
    int attackanimation = 0;
    uint64_t meleeattacktime = 0;
	
	/*
	int health = 100;// "Health"
	int team = 0;// "Team" ["Good", "Bad", "Neutral"]
	bool enabled = true;// "Enabled"
	WString alertsound = "";// "Alert sound" SOUND
	WString attacksound1 = "";// "Attack sound 1" SOUND
	WString attacksound2 = "";// "Attack sound 2" SOUND
	shared_ptr<Entity> target;// "Target"
	virtual void Enable();//in
	*/
	
    Monster();

    virtual void Start();
    virtual void Update();
    virtual void Collide(std::shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed);
    virtual std::shared_ptr<Component> Copy();
    static void EndAttackHook(shared_ptr<Skeleton> skeleton, shared_ptr<Object> extra);
    virtual std::any CallMethod(shared_ptr<Component> caller, const WString& name, const std::vector<std::any>& args);
};