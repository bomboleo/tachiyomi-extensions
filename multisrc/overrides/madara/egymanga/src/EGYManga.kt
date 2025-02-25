package eu.kanade.tachiyomi.extension.ar.egymanga

import eu.kanade.tachiyomi.multisrc.madara.Madara
import eu.kanade.tachiyomi.source.model.SChapter
import okhttp3.Response
import java.text.SimpleDateFormat
import java.util.Locale

class EGYManga : Madara("EGY Manga", "https://egymanga.net", "ar", SimpleDateFormat("MMMM dd, yyyy", Locale("ar"))) {
    override fun chapterListParse(response: Response): List<SChapter> = super.chapterListParse(response).reversed()
    override val pageListParseSelector = "div.separator"
}
