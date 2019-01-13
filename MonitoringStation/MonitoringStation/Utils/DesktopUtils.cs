using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Forms;
using System.IO;

namespace MonitoringStation.Utils
{
    public static class DesktopUtils
    {
        private static Rectangle DesktopResolution;

        public static bool Compress;

            
        static DesktopUtils()
        {
            DesktopResolution = Screen.PrimaryScreen.Bounds;
            Compress = true;
        }

        public static int TakeScreenshot()
        {
            Bitmap memoryImage;
            memoryImage = new Bitmap(DesktopResolution.Width, DesktopResolution.Height);
            Size s = new Size(memoryImage.Width, memoryImage.Height);

            Graphics memoryGraphics = Graphics.FromImage(memoryImage);

            memoryGraphics.CopyFromScreen(0, 0, 0, 0, s);

            MemoryStream str = new MemoryStream();

            if (Compress)
            {
                var resized = new Bitmap(memoryImage, new Size(memoryImage.Width/5,memoryImage.Height/5));
                resized.Save(str,ImageFormat.Png);
            }
            else
            {
                memoryImage.Save(str, ImageFormat.Png);
            }

            return str.ToArray().Length;

        }

    }
}
