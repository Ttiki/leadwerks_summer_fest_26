#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"
#include "Player.h"

using namespace Leadwerks;

class SrcPlayer : public Player//Component
{
protected:
	shared_ptr<Collider> deadbodycollider;
	std::shared_ptr<Sound> sound_jump;
	std::array<std::shared_ptr<Sound>, 4> sound_step;
	std::array<std::shared_ptr<Sound>, 3> sound_hit;
	bool freelookstarted{ false };
	Vec3 freelookmousepos;
	Vec3 freelookrotation;
	Vec2 lookchange;
	Vec2 mousedelta;
	Vec3 currentcameraposition;
	uint64_t lastfootsteptime = 0;
	bool jumpkey = false;
	bool running = false;
	bool walking = false;
	std::shared_ptr<NavMesh> navmesh;
	std::shared_ptr<NavAgent> agent;
	Quat camerashakerotation;
	Quat smoothedcamerashakerotation;
	Quat flashlightrotation;
	Vec3 movement;

public: 
    /*int integervalue = 0;//"Integer value"
    float floatvalue = 0.0f;//"Float value"
    WString stringvalue = "";//"String value"
    bool booleanvalue = false;//"Boolean value"
    int optionvalue = 0;//"Option value" ["Option 1", "Option 2", "Option 3"]
    std::shared_ptr<Entity> entityvalue;//"Entity value"
    WString pathvalue;//"Path value" SOUND
    Vec2 vec2value = Vec2(0,0);//"Vec2 value"
    Vec3 vec3value = Vec3(0,0,0);//"Vec3 value"
    Vec4 vec4value = Vec4(0,0,0,0);//"Vec4 value"
    Vec3 rgbvalue = Vec3(1,1,1);//"RGB value" COLOR
    Vec4 rgbavalue = Vec4(1,1,1,1);//"RGBA value" COLOR*/

	shared_ptr<Camera> camera;

	float fov = 70.0f;//FOV
	float eyeheight = 1.65f;//"Eye height"
	float croucheyeheight = 0.7f;//"Crouch height"
	float mousesmoothing = 0.0f;//"Mouse smoothing"
	float mouselookspeed = 1.0f;//"Look speed"

	float movespeed = 4.0f;//"Move speed"
	
	float walkSpeed = 5.0f; //"Walk speed"
	float runSpeed = 10.0f; //"Run speed (default)"
	float sprintSpeed = 15.0f; //"Sprint speed"

    float maxWalkSpeed = runSpeed;

	float jumpforce = 4.2f;//"Jump force"
	float jumplunge = 1.2f;//"Jump lunge"

	float groundAccMultiplier = 1.0f; //"Ground acceleration multiplier"
	float airAccMultiplier = 0.5f; //"Air acceleration multiplier"

	float airSpeedCap = 10.0f; //"Air speed cap"
	float airSlideSpeedCap = 5.0f; //"Air slide speed cap"

	float groundBreakingFriction = 5.0f; //"Ground breaking friction"
	float brakingFriction = 1.0f; //"Breaking friction"
	float surfaceFriction = 1.0f; //"Surface friction"

	float edgeFrictionMultiplier = 0.5f; //"Edge friction multiplier"
	float edgeFrictionHeight = 0.5f; //"Edge friction height"
	float edgeFrictionDist = 0.5f; //"Edge friction distance"

	bool bEdgeFrictionOnlyBreaking = false; //"Edge friction only breaking"
	bool bEdgeFrictionAlwaysCrouching = false; //"Edge friction always crouching"

	float brekingFrictionMultiplier = 1.0f; //"Breaking friction multiplier"
	float breakingSubStepTime = 1 / 60.0f; //"Breaking sub-step time"


    virtual void Start();
    virtual void Update();
    virtual void Collide(std::shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed);
    virtual bool ProcessEvent(const Event& e);
	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual bool Save(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();

	virtual void UpdateFootsteps();
};