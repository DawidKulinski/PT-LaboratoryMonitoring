using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;
using System.Management;
using System.Text;
using System.Configuration;
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

            RabbitMqUtils.Send(Encoding.ASCII.GetBytes(ConfigurationManager.AppSettings["UserName"]),"init");

            Task.Run(() =>
            {
                while(true)
                {
                    Thread.Sleep(5 * 1000);
                    RabbitMqUtils.Send(DesktopUtils.TakeScreenshot(), "screenshot");
                }
            });

            RabbitMqUtils.Receive();

            var autoResetEvent = new AutoResetEvent(false);

            ManagementEventWatcher startWatch = new ManagementEventWatcher(
                new WqlEventQuery(WmiProcessCreate));
            startWatch.EventArrived += ProcessUtils.OnProcessCreated;


            //Console.WriteLine("Listing all current processes:");
            //foreach (var s in ProcessUtils.GetProcessList())
            //{
            //    RabbitMqUtils.Send(Encoding.ASCII.GetBytes(s), "update");
            //}
            //Console.WriteLine("End of the list.");

            startWatch.Start();

            autoResetEvent.WaitOne();

            Console.ReadKey();

        }
    }
}
