const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// ✅ Cambia esto por tu Gmail y contraseña de aplicación
const GMAIL_EMAIL = 'soporte.nexify@gmail.com';
const GMAIL_PASSWORD = 'reeq bwts ioil vref';

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: GMAIL_EMAIL,
    pass: GMAIL_PASSWORD,
  },
});

exports.notificarCambioPassword = functions.firestore
  .document('notificaciones/{userId}/mensajes/{mensajeId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userId = context.params.userId;

    if (data.titulo !== 'Actualización de contraseña') return null;

    const user = await admin.auth().getUser(userId);

    const mailOptions = {
      from: `"Imagro Soporte" <${GMAIL_EMAIL}>`,
      to: user.email,
      subject: 'Cambio de contraseña realizado',
      html: `
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cambio de Contraseña - Imagro</title>
      </head>
      <body style="font-family: 'Poppins', sans-serif; margin: 0; padding: 0; background-color: #f9f9f9; color: #333;">
        <div style="max-width: 600px; margin: 40px auto; background: #ffffff; border-radius: 10px; overflow: hidden; box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.1);">
          <div style="background-color: #0ba27f; padding: 30px; text-align: center; color: #ffffff;">
            <img src="https://i.imgur.com/gEvCgqP.png" alt="Imagro Logo" style="width: 100px; margin-bottom: 10px;">
            <h2 style="margin: 10px 0;">Tu contraseña fue actualizada</h2>
          </div>
          <div style="padding: 30px; text-align: center;">
            <p>Hola <strong>${user.displayName || 'usuario'}</strong>,</p>
            <p>Queremos informarte que tu contraseña fue <strong>modificada correctamente</strong> en el sistema Imagro.</p>
            <p><strong>Fecha:</strong> ${new Date(data.fecha._seconds * 1000).toLocaleString()}</p>
            <p style="margin-top: 30px;">Si no realizaste este cambio, contacta con soporte inmediatamente.</p>
            <a href="mailto:soporte.nexify@gmail.com" 
              style="display: inline-block; background-color: #0ba27f; color: white; text-decoration: none; font-weight: bold; padding: 12px 20px; border-radius: 5px; margin-top: 20px;">
              Contactar soporte
            </a>
          </div>
          <div style="background-color: #0ba27f; color: #ffffff; text-align: center; padding: 20px; font-size: 14px;">
            <p>Contacto</p>
            <p>Kevin Darling Ponce Rivera</p>
            <p><a href="mailto:soporte.nexify@gmail.com" style="color: #ffffff; text-decoration: underline;">soporte.nexify@gmail.com</a></p>
            <div style="margin-top: 10px;">
              <a href="#"><img src="https://cdn-icons-png.flaticon.com/512/733/733547.png" width="24" alt="Facebook" style="margin: 0 8px;"></a>
              <a href="#"><img src="https://cdn-icons-png.flaticon.com/512/733/733558.png" width="24" alt="Twitter" style="margin: 0 8px;"></a>
              <a href="#"><img src="https://cdn-icons-png.flaticon.com/512/2111/2111463.png" width="24" alt="Instagram" style="margin: 0 8px;"></a>
            </div>
            <p style="margin-top: 10px;">&copy; ${new Date().getFullYear()} Imagro | Todos los derechos reservados</p>
          </div>
        </div>
      </body>
      </html>


      `
      ,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log('✅ Correo enviado a:', user.email);
    } catch (error) {
      console.error('❌ Error al enviar correo:', error);
    }

    return null;
  });

  exports.enviarCorreoBienvenida = functions.firestore
  .document('notificaciones/{userId}/mensajes/{mensajeId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userId = context.params.userId;

    if (data.titulo !== 'Bienvenido a Imagro') return null;

    const user = await admin.auth().getUser(userId);

    const mailOptions = {
      from: `"Imagro Soporte" <${GMAIL_EMAIL}>`,
      to: user.email,
      subject: '¡Bienvenido a Imagro!',
      html: `
        <div style="font-family: Poppins, sans-serif; background-color: #f9f9f9; padding: 30px;">
          <div style="max-width: 600px; margin: auto; background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 0 10px rgba(0,0,0,0.1);">
            <div style="background-color: #0ba27f; color: white; padding: 30px; text-align: center;">
              <img src="https://i.imgur.com/gEvCgqP.png" alt="Imagro Logo" style="width: 100px; margin-bottom: 10px;">
              <h2 style="margin: 0;">¡Bienvenido a Imagro!</h2>
            </div>
            <div style="padding: 30px; color: #333; text-align: center;">
              <p>Hola <strong>${user.displayName || 'usuario'}</strong>,</p>
              <p>Tu cuenta fue creada exitosamente. Ahora puedes acceder a todos los servicios de Imagro.</p>
              <p>Gracias por formar parte de nuestra comunidad.</p>
              <a href="https://imagroweb.netlify.app"
                 style="display: inline-block; margin-top: 20px; padding: 12px 24px; background-color: #0ba27f; color: white; border-radius: 5px; text-decoration: none;">
                 Ir al sitio
              </a>
            </div>
            <div style="background-color: #0ba27f; color: white; text-align: center; padding: 20px; font-size: 12px;">
              &copy; ${new Date().getFullYear()} Imagro - Todos los derechos reservados
            </div>
          </div>
        </div>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log('✅ Correo de bienvenida enviado a:', user.email);
    } catch (error) {
      console.error('❌ Error al enviar correo de bienvenida:', error);
    }

    return null;
  });


  //ENVIAR CORREO DE CONTRIBUCION ENVIADA A REVISION
  exports.notificarContribucionEnviada = functions.firestore
  .document('notificaciones/{userId}/mensajes/{mensajeId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const userId = context.params.userId;

    if (data.titulo !== 'Contribución enviada') return null;

    const user = await admin.auth().getUser(userId);

    const mailOptions = {
      from: `"Imagro Soporte" <${GMAIL_EMAIL}>`,
      to: user.email,
      subject: 'Contribución recibida',
      html: `
        <div style="font-family: Poppins, sans-serif; background-color: #f9f9f9; padding: 20px;">
          <div style="background: white; border-radius: 8px; padding: 30px; box-shadow: 0px 4px 12px rgba(0,0,0,0.1);">
            <h2 style="color: #0BA37F;">¡Gracias por tu contribución!</h2>
            <p>Hola <strong>${user.displayName || 'usuario'}</strong>,</p>
            <p>Hemos recibido tu contribución y será procesada por nuestro equipo.</p>
            <p style="color: gray;"><small>Fecha: ${new Date(data.fecha._seconds * 1000).toLocaleString()}</small></p>
            <p>Gracias por ser parte de Imagro.</p>
          </div>
        </div>
      `,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log('📤 Correo de confirmación enviado a:', user.email);
    } catch (error) {
      console.error('❌ Error al enviar correo:', error);
    }

    return null;
  });


