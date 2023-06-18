import { RequestHandler } from '@sveltejs/kit';
import prisma from '$lib/prisma';



export async function GET(request) {
  console.log(request.url.searchParams.get('id'))
  try {
    const students = await prisma.student.findMany({
      include: {
        grades: true,
      },
    })
    return new Response(JSON.stringify({
      status: 200,
      body: students,
    }))
  } catch (error) {
    return new Response(JSON.stringify({
      status: 500,
      body: { error: 'An error occurred while fetching students' },
    }))
  }
}




