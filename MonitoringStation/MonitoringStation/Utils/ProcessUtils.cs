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
        private static List<string> BlockedProcesses;

        static ProcessUtils()
        {
            BlockedProcesses = new List<string>();
        }

        public static IEnumerable<string> GetProcessList()
        {
            return Process.GetProcesses().Select(x => x.ProcessName);
        }

        public static void OnProcessCreated(object sender, EventArrivedEventArgs e)
        {
            var newProcessName = e.NewEvent.Properties["ProcessName"].Value as string;
            newProcessName = newProcessName.Substring(0, newProcessName.Length - 4);

            if(BlockedProcesses.Contains(newProcessName))
            {
                var process = Process.GetProcessesByName(newProcessName);
                process.ToList().ForEach(x => x.Kill());
            }

            Console.WriteLine($"Process Created: {newProcessName}");
            RabbitMqUtils.Send(Encoding.ASCII.GetBytes(newProcessName),"update");
        }

        public static void ProcessStateChange(string processName)
        {
            if (BlockedProcesses.Contains(processName))
            {
                BlockedProcesses.Remove(processName);
            }
            else
            {
                BlockedProcesses.Add(processName);
                var process = Process.GetProcessesByName(processName);
                process.ToList().ForEach(x => x.Kill());
            }
        }

    }
}
