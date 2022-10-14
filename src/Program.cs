using System;
using System.Windows.Forms;
using System.Drawing;

namespace program {
    class program {
        private static void Main(){
            Form mainForm = new Form();
            Label hw = new Label();
            mainForm.Width = 300;
            mainForm.Height = 500;
            hw.Text = "Hello, world!";
            hw.Location = new Point(150, 200);
            mainForm.Controls.Add(hw);
            Application.Run(mainForm);
        }
    }
}