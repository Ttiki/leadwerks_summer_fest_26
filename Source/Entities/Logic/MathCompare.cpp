#pragma once
#include "Leadwerks.h"
#include "MathCompare.h"

using namespace Leadwerks;

void MathCompare::Start()
{
    //Listen(EVENT_KEYDOWN, NULL);// makes this component listen for keydown events from all windows
}

void MathCompare::Test(const int value2Test)//inout
{
	if (!enabled) return;
    switch (test)
    {
    case 0: // <
        if (value2Test < testValue) FireOutputs("True");
        break;
    case 1: // >
        if (value2Test > testValue) FireOutputs("True");
        break;
    case 2: // =
        if (value2Test == testValue) FireOutputs("True");
        break;
    }
}

bool MathCompare::Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra)
{

    if (properties["testValue"].is_number()) testValue = properties["testValue"];
    if (properties["enabled"].is_number()) enabled = properties["enabled"];
    return BaseComponent::Load(properties, binstream, scene, flags, extra);
}

bool MathCompare::Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra)
{
    properties["testValue"] = testValue;
    properties["enabled"] = enabled;
    return BaseComponent::Save(properties, binstream, scene, flags, extra);
}

//This method will work with simple components
shared_ptr<Component> MathCompare::Copy()
{
    return std::make_shared<MathCompare>(*this);
}

std::any MathCompare::CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments)
{
    if (name == "Test")
    {
        if (arguments.size() >= 1 and std::string(arguments[0].type().name()) == "int")
        {
            Test(std::any_cast<int>(arguments[0]));
        }
    }
    return BaseComponent::CallMethod(sender, name, arguments);

}