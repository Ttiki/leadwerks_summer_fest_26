#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class FuncBrush : public BaseComponent//Component
{
public: 
    
   
    int collisionMode = 0;//"collision Mode" ["Solid", "Non-solid"]
	bool enabled = true;//"Enabled" 
    Vec3 color = Vec3(1,1,1);//"Mesh color" COLOR

    virtual void Start();
    virtual void ToggleCollision();
	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual bool Save(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments);
};