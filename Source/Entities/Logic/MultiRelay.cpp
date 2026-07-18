#pragma once
#include "Leadwerks.h"
#include "MultiRelay.h"

using namespace Leadwerks;

void MultiRelay::Update() {
    if (queue.empty()) return;
        
    auto entity = GetEntity();
    auto world = entity->GetWorld();
    auto currentTime = world->GetTime();

    // Remove timers that are due
    auto it = queue.begin();
    while (it != queue.end())
    {
        if (currentTime > it->time)
        {
            FireOutputs(it->output);
            it = queue.erase(it);
            continue;
        }
        ++it;
    }
}

void MultiRelay::Signal()
{
    if (not GetEnabled()) return;

    auto entity = GetEntity();
    auto world = entity->GetWorld();
    auto currentTime = world->GetTime();
    TimedSignal t;

    // For Output1
    if (delay1 == 0)
    {
        FireOutputs("Output1");
    }
    else
    {
        t.time = currentTime + delay1 * 1000;
        t.output = "Output1";
        queue.push_back(t);
    }

    // For Output2
    if (delay2 == 0)
    {
        FireOutputs("Output2");
    }
    else
    {
        t.time = currentTime + delay2 * 1000;
        t.output = "Output2";
        queue.push_back(t);
    }

    // For Output3
    if (delay3 == 0)
    {
        FireOutputs("Output3");
    }
    else
    {
        t.time = currentTime + delay3 * 1000;
        t.output = "Output3";
        queue.push_back(t);
    }

    // For Output4
    if (delay4 == 0)
    {
        FireOutputs("Output4");
    }
    else
    {
        t.time = currentTime + delay4 * 1000;
        t.output = "Output4";
        queue.push_back(t);
    }

    // For Output5
    if (delay5 == 0)
    {
        FireOutputs("Output5");
    }
    else
    {
        t.time = currentTime + delay5 * 1000;
        t.output = "Output5";
        queue.push_back(t);
    }

    // For Output6
    if (delay6 == 0)
    {
        FireOutputs("Output6");
    }
    else
    {
        t.time = currentTime + delay6 * 1000;
        t.output = "Output6";
        queue.push_back(t);
    }

    // For Output7
    if (delay7 == 0)
    {
        FireOutputs("Output7");
    }
    else
    {
        t.time = currentTime + delay7 * 1000;
        t.output = "Output7";
        queue.push_back(t);
    }

    // For Output8
    if (delay8 == 0)
    {
        FireOutputs("Output8");
    }
    else
    {
        t.time = currentTime + delay8 * 1000;
        t.output = "Output8";
        queue.push_back(t);
    }
}

void MultiRelay::Output1()
{
    FireOutputs("Outputs1");
}

void MultiRelay::Output2()
{
    FireOutputs("Outputs2");
}

void MultiRelay::Output3()
{
    FireOutputs("Outputs3");
}

void MultiRelay::Output4()
{
    FireOutputs("Outputs4");
}

void MultiRelay::Output5()
{
    FireOutputs("Outputs5");
}

void MultiRelay::Output6()
{
    FireOutputs("Outputs6");
}

void MultiRelay::Output7()
{
    FireOutputs("Outputs7");
}

void MultiRelay::Output8()
{
    FireOutputs("Outputs8");
}

bool MultiRelay::Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra)
{
    if (properties["delay1"].is_number()) delay1 = properties["delay1"];
    if (properties["delay2"].is_number()) delay2 = properties["delay2"];
    if (properties["delay3"].is_number()) delay3 = properties["delay3"];
    if (properties["delay4"].is_number()) delay4 = properties["delay4"];
    if (properties["delay5"].is_number()) delay5 = properties["delay5"];
    if (properties["delay6"].is_number()) delay6 = properties["delay6"];
    if (properties["delay7"].is_number()) delay7 = properties["delay7"];
    if (properties["delay8"].is_number()) delay8 = properties["delay8"];
    return BaseComponent::Load(properties, binstream, scene, flags, extra);
}

//This method will work with simple components
shared_ptr<Component> MultiRelay::Copy()
{
    return std::make_shared<MultiRelay>(*this);
}

std::any MultiRelay::CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments)
{
    if (name == "Signal")
    {
        Signal();
        return false;
    }
    return BaseComponent::CallMethod(sender, name, arguments);
}