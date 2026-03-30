from collections import defaultdict

from .reward_function_base import BaseRewardFunction


class GunKillReward(BaseRewardFunction):
    """
    Reward artillery-based kills once when an enemy transitions into shotdown.
    """

    def __init__(self, config):
        super().__init__(config)
        self._enemy_shotdown_flags = defaultdict(dict)

    def reset(self, task, env):
        super().reset(task, env)
        self._enemy_shotdown_flags.clear()
        for agent_id, agent in env.agents.items():
            self._enemy_shotdown_flags[agent_id] = {
                enemy.uid: enemy.is_shotdown for enemy in agent.enemies
            }

    def get_reward(self, task, env, agent_id):
        reward = 0
        enemy_flags = self._enemy_shotdown_flags[agent_id]
        for enemy in env.agents[agent_id].enemies:
            if enemy.is_shotdown and not enemy_flags.get(enemy.uid, False):
                reward += 200
            enemy_flags[enemy.uid] = enemy.is_shotdown
        return self._process(reward, agent_id)
