using System;
using System.Collections.Generic;
using System.Linq;
using System.Management;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using MonitoringStation.Utils;

namespace MonitoringStation
{
    class Program
    {
        private const string WmiProcessCreate = "SELECT * FROM Win32_ProcessStartTrace";

        static void Main(string[] args)
        {
            var autoResetEvent = new AutoResetEvent(false);

            ManagementEventWatcher startWatch = new ManagementEventWatcher(
                new WqlEventQuery(WmiProcessCreate));
            startWatch.EventArrived += ProcessUtils.OnProcessCreated;


            Console.WriteLine("Listing all current processes:");
            foreach (var s in ProcessUtils.GetProcessList())
            {
                RabbitMqUtils.Send(Encoding.ASCII.GetBytes(s));
            }
            Console.WriteLine("End of the list.");

            startWatch.Start();
            autoResetEvent.WaitOne();

        }
    }
}
