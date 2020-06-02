import sys
import math

if sys.platform == 'win32':  # Windows
    path_to_sim_atav = 'D:/git_repos/sim-atav-assembla'
else:  # Linux / Mac OS
    path_to_sim_atav = '/Users/erkan/git_repos/sim-atav_public'
sys.path.append(path_to_sim_atav)  # This is needed for the calls from Matlab
from Sim_ATAV.simulation_control.sim_data import SimData
from Sim_ATAV.simulation_control.webots_fog import WebotsFog
from Sim_ATAV.simulation_control.webots_vehicle import WebotsVehicle
from Sim_ATAV.simulation_control.webots_road import WebotsRoad
from Sim_ATAV.simulation_control.heart_beat import HeartBeatConfig
from Sim_ATAV.simulation_control.item_description import ItemDescription
from Sim_ATAV.simulation_configurator import sim_config_tools
from Sim_ATAV.simulation_configurator.sim_environment import SimEnvironment
from Sim_ATAV.simulation_configurator.view_follow_config import ViewFollowConfig
from Sim_ATAV.simulation_configurator.sim_environment_configurator import SimEnvironmentConfigurator


def test1():
    sim_config = sim_config_tools.SimulationConfig(1)
    sim_config.run_config_arr.append(sim_config_tools.RunConfig())
    sim_config.run_config_arr[0].simulation_run_mode = SimData.SIM_TYPE_RUN
    sim_config.sim_duration_ms = 100000
    sim_config.sim_step_size = 10
    sim_config.world_file = '../Webots_Projects/worlds/empty_world.wbt'

    sim_env_configurator = SimEnvironmentConfigurator(sim_config=sim_config)
    (is_connected, simulator_instance) = sim_env_configurator.connect(max_connection_retry=3)
    if not is_connected:
        raise ValueError('Could not connect!')
    return sim_env_configurator




def set_initial_states(states):
    """Runs a test with the given arguments"""
    # states: x,y,theta (repeated for all vehicles)
    follow_height = 100.0

    sim_environment = SimEnvironment()
    # --- Add road
    road = WebotsRoad(number_of_lanes=5)
    road.width = 17.5
    road.rotation = [0, 1, 0, -math.pi / 2]
    road.position = [1000, 0.02, 0]
    road.length = 5000.0
    sim_environment.road_list.append(road)

    color_options = [[1.0, 1.0, 0.0], [1.0, 0.0, 0.0], [0.0, 0.0, 1.0], [0.0, 1.0, 0.0], [1.0, 1.0, 1.0], [0.0, 0.0, 0.0]]

    # ----- Define VEHICLES:
    num_states_per_vhc = 3
    num_vhc = int(len(states) / num_states_per_vhc)
    for i in range(num_vhc):
        vhc_obj = WebotsVehicle()
        vhc_obj.current_position = [states[i*num_states_per_vhc], 0.32, states[i*num_states_per_vhc + 1]]
        vhc_obj.current_orientation = states[i*num_states_per_vhc + 2]
        vhc_obj.rotation = [0.0, 1.0, 0.0, vhc_obj.current_orientation]
        vhc_obj.vhc_id = i+1
        vhc_obj.color = color_options[i]
        vhc_obj.set_vehicle_model('TeslaModel3Simple')
        #vhc_obj.is_controller_name_absolute = True
        # vhc_obj.controller = 'empty_controller'
        sim_environment.ego_vehicles_list.append(vhc_obj)

    # ----- Fog:
    sim_environment.fog = WebotsFog()
    sim_environment.fog.visibility_range = 2000.0

    # ----- Heart Beat Configuration:
    sim_environment.heart_beat_config = HeartBeatConfig(sync_type=HeartBeatConfig.WITH_SYNC,
                                                        period_ms=10)

    sim_config = sim_config_tools.SimulationConfig(1)
    sim_config.run_config_arr.append(sim_config_tools.RunConfig())
    sim_config.run_config_arr[0].simulation_run_mode = SimData.SIM_TYPE_RUN
    sim_config.sim_duration_ms = 100000
    sim_config.sim_step_size = 10
    sim_config.world_file = '../Webots_Projects/worlds/empty_world.wbt'

    sim_env_configurator = SimEnvironmentConfigurator(sim_config=sim_config)
    (is_connected, simulator_instance) = sim_env_configurator.connect(max_connection_retry=3)
    if not is_connected:
        raise ValueError('Could not connect!')
    sim_env_configurator.setup_sim_environment(sim_environment)
    sim_env_configurator.comm_interface.set_view_point_position([states[0], follow_height, states[1]])
    sim_env_configurator.comm_interface.set_view_point_orientation([-1.0, 0.0, 0.0, math.pi/2])
    sim_env_configurator.start_simulation()
    received_heart_beat = sim_env_configurator.comm_interface.receive_heart_beat()

    return sim_env_configurator


def update_states(states, sim_env_configurator):
    """Runs a test with the given arguments"""
    # states: x,y,theta (repeated for all vehicles)
    # ----- Define VEHICLES:
    num_states_per_vhc = 3
    follow_height = 100.0
    num_vhc = int(len(states) / num_states_per_vhc)
    for i in range(num_vhc):
        vhc_obj = WebotsVehicle()
        vhc_obj.current_position = [states[i*num_states_per_vhc], 0.32, states[i*num_states_per_vhc + 1]]
        vhc_obj.current_orientation = states[i*num_states_per_vhc + 2]
        vhc_obj.rotation = [0.0, 1.0, 0.0, vhc_obj.current_orientation]
        vhc_obj.vhc_id = i+1
        sim_env_configurator.comm_interface.change_vehicle_position(vhc_obj)
        if i == 0:
            sim_env_configurator.comm_interface.set_view_point_position([vhc_obj.current_position[0], follow_height, vhc_obj.current_position[2]])
    sim_env_configurator.comm_interface.send_continue_sim_command()
    received_heart_beat = sim_env_configurator.comm_interface.receive_heart_beat()



#cc = set_initial_states([0.0, 0.0, math.pi/2.0, 10.0, 3.5, math.pi/4.0])
