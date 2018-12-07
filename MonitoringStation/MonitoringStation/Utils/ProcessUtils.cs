using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Management;

namespace MonitoringStation.Utils
{
    public static class ProcessUtils
    {
        public static IEnumerable<string> GetProcessList()
        {
            return Process.GetProcesses().Select(x => x.ProcessName);
        }

        public static void OnProcessCreated(object sender, EventArrivedEventArgs e)
        {
            Console.WriteLine($"Process Created: {e.NewEvent.Properties["ProcessName"].Value}");
        }

    }
}
