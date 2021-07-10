import csv
import pandas as pd
from enum import Enum
import matplotlib.pyplot as plt


class STATE(Enum):
    FULL = 1
    PARTIAL = 2
    SHUTDOWN = 3
    FP = 4
    PF = 5
    FS = 6
    SF = 7


BC_filename = 'gold/BC.csv'
result_filename = 'output/elastic_thermal_creep.csv'
output_filename = 'output/elastic_thermal_creep_fs.csv'

BC = pd.read_csv(BC_filename)
BC = BC.astype({'time': 'int64'})
result = pd.read_csv(result_filename)

result_with_state = result.join(BC.set_index('time'), on='time')

indices_full = result_with_state['state'] == STATE.FULL.value
indices_shutdown = result_with_state['state'] == STATE.SHUTDOWN.value
result_full_or_shutdown = result_with_state[indices_full | indices_shutdown]

result_full_or_shutdown.to_csv(output_filename)

plt.plot(result_full_or_shutdown['time'],
         result_full_or_shutdown['oxide_stress_rr'], '-')
plt.plot(result_full_or_shutdown['time'],
         result_full_or_shutdown['oxide_stress_zz'], '-')
plt.plot(result_full_or_shutdown['time'],
         result_full_or_shutdown['oxide_stress_tt'], '-')
plt.show()
