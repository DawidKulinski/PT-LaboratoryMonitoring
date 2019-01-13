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
            var newProcessName = e.NewEvent.Properties["ProcessName"].Value as string;
            Console.WriteLine($"Process Created: {newProcessName}");
            RabbitMqUtils.Send(Encoding.ASCII.GetBytes(newProcessName),"update");
        }

    }
}
