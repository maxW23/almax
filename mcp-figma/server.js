// /*
//  * سكربت تشغيل خادم MCP الخاص بـ Figma داخل Windsurf
//  * الفكرة: تشغيل الحزمة الرسمية @modelcontextprotocol/server-figma عبر npx باستخدام بروتوكول stdio
//  * المتطلبات:
//  *  - ضبط متغير البيئة FIGMA_ACCESS_TOKEN (سيتم وضعه من طرفك في بيئة آمنة)
//  *  - لا يلزم أي إعدادات إضافية؛ Windsurf سيقرأ الملف .windsurf/cascade.json ويشغل الخادم تلقائياً
//  */

// const { spawn } = require('child_process');
// const fs = require('fs');
// const path = require('path');

// // تحميل متغيرات من ملف .env في جذر المشروع (سلوك مشابه لـ EnvLoader.get)
// try {
//   const envPath = path.resolve(__dirname, '..', '.env');
//   if (fs.existsSync(envPath)) {
//     const content = fs.readFileSync(envPath, 'utf8');
//     content.split(/\r?\n/).forEach((line) => {
//       const trimmed = line.trim();
//       if (!trimmed || trimmed.startsWith('#')) return;
//       const eq = trimmed.indexOf('=');
//       if (eq === -1) return;
//       const key = trimmed.slice(0, eq).trim();
//       const val = trimmed.slice(eq + 1).trim().replace(/^"|"$/g, '');
//       if (!process.env[key]) process.env[key] = val;
//     });
//     // ℹ️ تم تحميل متغيرات البيئة من .env (جذر المشروع) — لا نطبع إلى stdout لتجنب كسر بروتوكول MCP
//   }
// } catch (e) {
//   console.warn('⚠️ تعذر قراءة ملف .env:', e?.message || e);
// }

// // تذكير مهم للمطور: تأكد من توفر التوكن كمتغير بيئة قبل التشغيل
// if (!process.env.FIGMA_ACCESS_TOKEN) {
//   console.warn(
//     '\n[تحذير] لم يتم العثور على FIGMA_ACCESS_TOKEN في متغيرات البيئة.\n' +
//       'سيُحاول الخادم البدء، لكن لن تعمل أدوات Figma بدون توكن صالح.\n' +
//       'قم بإعداد المتغير ثم أعد التشغيل.\n'
//   );
// }

// // على mac/*nix يكون الأمر npx، وعلى Windows npx.cmd
// const npxCmd = process.platform === 'win32' ? 'npx.cmd' : 'npx';
// const args = ['-y', '@modelcontextprotocol/server-figma', '--stdio'];

// // ▶️ بدء تشغيل خادم MCP لـ Figma باستخدام stdio... — لا نطبع إلى stdout

// const child = spawn(npxCmd, args, {
//   stdio: 'inherit', // مشاركة نفس قنوات الإدخال/الإخراج مع العملية الأم (مطلوب لـ stdio)
//   env: {
//     ...process.env,
//     // إجبار النقل عبر stdio (توافق مع معظم خوادم MCP)
//     MCP_TRANSPORT: 'stdio',
//   },
// });

// child.on('exit', (code, signal) => {
//   if (signal) {
//     console.error(`⏹️ تم إيقاف خادم MCP عبر الإشارة: ${signal}`);
//   } else {
//     console.error(`⏹️ تم إنهاء خادم MCP برمز: ${code}`);
//   }
// });

// child.on('error', (err) => {
//   console.error('حدث خطأ أثناء تشغيل خادم MCP:', err);
//   process.exitCode = 1;
// });
