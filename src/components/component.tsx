/**
* This code was generated by v0 by Vercel.
* @see https://v0.dev/t/Df7cCUjrXXg
* Documentation: https://v0.dev/docs#integrating-generated-code-into-your-nextjs-app
*/

/** Add fonts into your Next.js project:

import { Inter } from 'next/font/google'

inter({
  subsets: ['latin'],
  display: 'swap',
})

To read more about using these font, please visit the Next.js documentation:
- App Directory: https://nextjs.org/docs/app/building-your-application/optimizing/fonts
- Pages Directory: https://nextjs.org/docs/pages/building-your-application/optimizing/fonts
**/
import { Card, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"

export function Component() {
  return (
    <div className="max-w-2xl mx-auto p-4 sm:p-6 lg:p-8">
      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-2">
          <h1 className="text-2xl font-bold">Remember the Past</h1>
          <p className="text-muted-foreground">Add events to your memory bank and keep track of the past.</p>
        </div>
        <Card>
          <CardContent className="grid gap-4">
            <div className="flex items-center gap-2">
              <Input type="text" placeholder="Add a new event" className="flex-1" />
              <Button type="submit">Add Event</Button>
            </div>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Button variant="ghost">Clear All</Button>
                <Button variant="ghost">Export</Button>
                <Button variant="ghost">Import</Button>
              </div>
            </div>
          </CardContent>
        </Card>
        <div className="grid gap-2">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-bold">Events</h2>
            <div className="text-sm text-muted-foreground">{new Date().toLocaleDateString()}</div>
          </div>
          <Card>
            <CardContent className="grid gap-2">
              <article className="flex items-center justify-between gap-4 p-3 text-sm transition-colors border rounded-md hover:bg-accent">
                <div className="flex items-center gap-2">
                  <CalendarIcon className="w-5 h-5 text-muted-foreground" />
                  <div>Went to the beach with friends</div>
                </div>
                <div className="text-xs text-muted-foreground">June 15, 2023</div>
              </article>
              <article className="flex items-center justify-between gap-4 p-3 text-sm transition-colors border rounded-md hover:bg-accent">
                <div className="flex items-center gap-2">
                  <CalendarIcon className="w-5 h-5 text-muted-foreground" />
                  <div>Celebrated my birthday</div>
                </div>
                <div className="text-xs text-muted-foreground">April 30, 2023</div>
              </article>
              <article className="flex items-center justify-between gap-4 p-3 text-sm transition-colors border rounded-md hover:bg-accent">
                <div className="flex items-center gap-2">
                  <CalendarIcon className="w-5 h-5 text-muted-foreground" />
                  <div>Went on a hike in the mountains</div>
                </div>
                <div className="text-xs text-muted-foreground">September 2, 2022</div>
              </article>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}

function CalendarIcon(props) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M8 2v4" />
      <path d="M16 2v4" />
      <rect width="18" height="18" x="3" y="4" rx="2" />
      <path d="M3 10h18" />
    </svg>
  )
}
