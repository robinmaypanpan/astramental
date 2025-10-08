class_name BuildingComponentData
extends Resource

func make_component(building_entity: BuildingEntity) -> BuildingComponent:
    return BuildingComponent.new(self, building_entity)